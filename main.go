package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"gopkg.in/yaml.v2"
)

// Config represents the application configuration
type Config struct {
	Server struct {
		Port int    `yaml:"port"`
		Host string `yaml:"host"`
	} `yaml:"server"`
	Database struct {
		Host     string `yaml:"host"`
		Port     int    `yaml:"port"`
		User     string `yaml:"user"`
		Password string `yaml:"password"`
		Name     string `yaml:"name"`
		SSLMode  string `yaml:"sslmode"`
	} `yaml:"database"`
	Auth struct {
		Username string `yaml:"username"`
		Password string `yaml:"password"`
	} `yaml:"auth"`
}

type Project struct {
	Name      string    `json:"name"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	Tables    []string  `json:"tables,omitempty"`
}

type DatabaseManager struct {
	db *sql.DB
}

type AppConfig struct {
	PostgresURL string
	Port        string
}

// loadConfig reads configuration from config.yaml
func loadConfig() (*Config, error) {
	config := &Config{}

	// Set default values
	config.Server.Port = 8090
	config.Server.Host = "0.0.0.0"
	config.Database.Host = "localhost"
	config.Database.Port = 5432
	config.Database.User = "postgres"
	config.Database.Password = "your-password"
	config.Database.Name = "postgres"
	config.Database.SSLMode = "disable"
	config.Auth.Username = "admin"
	config.Auth.Password = "supabase123"

	// Try to read from config file
	if data, err := os.ReadFile("config.yaml"); err == nil {
		if err := yaml.Unmarshal(data, config); err != nil {
			return nil, fmt.Errorf("failed to parse config.yaml: %v", err)
		}
	}

	return config, nil
}

// buildPostgresURL constructs a PostgreSQL connection string from config
func buildPostgresURL(config *Config) string {
	return fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=%s",
		config.Database.User,
		config.Database.Password,
		config.Database.Host,
		config.Database.Port,
		config.Database.Name,
		config.Database.SSLMode)
}

func main() {
	// Load configuration
	config, err := loadConfig()
	if err != nil {
		log.Printf("Warning: %v", err)
	}

	// Use environment variables if set, otherwise use config or defaults
	appConfig := &AppConfig{
		PostgresURL: getEnv("DATABASE_URL", buildPostgresURL(config)),
		Port:        getEnv("PORT", fmt.Sprintf("%d", config.Server.Port)),
	}

	// Connect to database
	db, err := sql.Open("postgres", appConfig.PostgresURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	dbManager := &DatabaseManager{db: db}

	// Setup Gin
	r := gin.Default()

	// Add authentication middleware for all routes except login
	authMiddleware := createAuthMiddleware(config.Auth.Username, config.Auth.Password)
	r.Use(authMiddleware)

	// Custom template functions
	funcMap := template.FuncMap{
		"json": func(v interface{}) template.JS {
			b, _ := json.Marshal(v)
			return template.JS(b)
		},
	}

	r.SetFuncMap(funcMap)
	// Load templates
	r.LoadHTMLGlob("templates/*")
	r.Static("/static", "./static")

	// Routes for authentication
	r.GET("/login", loginHandler)
	r.POST("/login", loginHandler)

	// Protected routes
	r.GET("/", dbManager.dashboardHandler)
	r.GET("/projects", dbManager.listProjects)
	r.POST("/projects", dbManager.createProject)
	r.DELETE("/projects/:name", dbManager.deleteProject)
	r.GET("/projects/:name/tables", dbManager.getProjectTables)
	r.POST("/projects/:name/query", dbManager.executeQuery)
	r.GET("/docker/status", dbManager.dockerStatus)
	r.POST("/docker/restart", dbManager.dockerRestart)
	r.GET("/api-help/:project", dbManager.apiHelpHandler)
	r.GET("/debug/schemas", dbManager.debugSchemasHandler) // Debug endpoint

	fmt.Printf("🚀 Supabase Manager running at http://localhost:%s\n", appConfig.Port)
	r.Run(":" + appConfig.Port)
}

func (dm *DatabaseManager) dashboardHandler(c *gin.Context) {
	projects, err := dm.getProjects()
	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{"error": err.Error()})
		return
	}

	dockerStatus := dm.getDockerStatus()

	// Convert projects and dockerStatus to JSON strings
	projectsJSON, _ := json.Marshal(projects)
	dockerStatusJSON, _ := json.Marshal(dockerStatus)

	// Get API endpoint from environment
	apiEndpoint := getEnv("SUPABASE_API_ENDPOINT", "")
	
	// Get Studio domain from environment
	studioDomain := getEnv("SUPABASE_STUDIO_DOMAIN", "")

	c.HTML(http.StatusOK, "dashboard.html", gin.H{
		"projects":     string(projectsJSON),
		"dockerStatus": string(dockerStatusJSON),
		"title":        "Supabase Project Manager",
		"apiEndpoint":  apiEndpoint,
		"studioDomain": studioDomain,
	})
}

func (dm *DatabaseManager) listProjects(c *gin.Context) {
	projects, err := dm.getProjects()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, projects)
}

func (dm *DatabaseManager) createProject(c *gin.Context) {
	var req struct {
		Name        string `json:"name" binding:"required"`
		Description string `json:"description"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate project name
	if !isValidProjectName(req.Name) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid project name. Use lowercase letters, numbers, and underscores only."})
		return
	}

	// Create schema in database
	if err := dm.createProjectSchema(req.Name); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to create schema: %v", err)})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": fmt.Sprintf("Project '%s' created successfully", req.Name),
		"project": req.Name,
	})
}

func (dm *DatabaseManager) deleteProject(c *gin.Context) {
	projectName := c.Param("name")

	if err := dm.deleteProjectSchema(projectName); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": fmt.Sprintf("Project '%s' deleted successfully", projectName)})
}

func (dm *DatabaseManager) getProjectTables(c *gin.Context) {
	projectName := c.Param("name")
	tables, err := dm.getTablesInSchema(projectName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"tables": tables})
}

func (dm *DatabaseManager) executeQuery(c *gin.Context) {
	projectName := c.Param("name")

	var req struct {
		Query string `json:"query" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set search path to project schema
	query := fmt.Sprintf("SET search_path TO %s, public; %s", projectName, req.Query)

	result, err := dm.executeQueryInProject(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"result": result})
}

func (dm *DatabaseManager) dockerStatus(c *gin.Context) {
	status := dm.getDockerStatus()
	c.JSON(http.StatusOK, status)
}

func (dm *DatabaseManager) dockerRestart(c *gin.Context) {
	cmd := exec.Command("docker-compose", "restart")
	output, err := cmd.CombinedOutput()

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":  err.Error(),
			"output": string(output),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Docker services restarted successfully",
		"output":  string(output),
	})
}

func (dm *DatabaseManager) apiHelpHandler(c *gin.Context) {
	projectName := c.Param("project")
	apiEndpoint := getEnv("SUPABASE_API_ENDPOINT", "")

	anonymousKey := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
	serviceRoleKey := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU"

	c.HTML(http.StatusOK, "api-help.html", gin.H{
		"project":        projectName,
		"apiEndpoint":    apiEndpoint,
		"anonymousKey":   anonymousKey,
		"serviceRoleKey": serviceRoleKey,
	})
}

// Debug handler to see all schemas
func (dm *DatabaseManager) debugSchemasHandler(c *gin.Context) {
	schemas, err := dm.getAllSchemas()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"schemas": schemas})
}

// FIXED: Helper functions
func (dm *DatabaseManager) getProjects() ([]Project, error) {
	query := `
		WITH user_schemas AS (
			SELECT s.schema_name,
			       CURRENT_TIMESTAMP as created_at,
			       COUNT(t.table_name) as table_count
			FROM information_schema.schemata s
			LEFT JOIN information_schema.tables t ON s.schema_name = t.table_schema
			WHERE s.schema_name NOT IN (
				'information_schema', 
				'pg_catalog', 
				'public'
			)
			-- Exclude all PostgreSQL system schemas
			AND s.schema_name !~ '^pg_'
			-- Exclude Supabase system schemas  
			AND s.schema_name NOT IN (
				'auth', 
				'storage', 
				'supabase_functions', 
				'extensions', 
				'realtime', 
				'vault', 
				'graphql', 
				'graphql_public'
			)
			-- Exclude TimescaleDB schemas if present
			AND s.schema_name !~ '^_timescaledb_'
			GROUP BY s.schema_name
			HAVING COUNT(t.table_name) > 0  -- Only schemas with tables
		)
		SELECT schema_name, created_at
		FROM user_schemas
		ORDER BY schema_name
	`

	rows, err := dm.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var projects []Project
	for rows.Next() {
		var p Project
		if err := rows.Scan(&p.Name, &p.CreatedAt); err != nil {
			log.Printf("Error scanning project: %v", err)
			continue
		}

		// Get table count for each project
		tables, err := dm.getTablesInSchema(p.Name)
		if err != nil {
			log.Printf("Error getting tables for schema %s: %v", p.Name, err)
			tables = []string{}
		}
		p.Tables = tables
		p.Status = "active"

		projects = append(projects, p)
	}

	return projects, nil
}

// Helper function to debug what schemas exist
func (dm *DatabaseManager) getAllSchemas() ([]map[string]interface{}, error) {
	query := `
		SELECT s.schema_name, 
		       CASE 
		           WHEN s.schema_name LIKE 'pg_%' THEN 'PostgreSQL System'
		           WHEN s.schema_name IN ('information_schema') THEN 'SQL Standard'
		           WHEN s.schema_name IN ('auth', 'storage', 'supabase_functions', 'extensions', 'realtime', 'vault', 'graphql', 'graphql_public') THEN 'Supabase System'
		           WHEN s.schema_name = 'public' THEN 'Default Public'
		           ELSE 'User Schema'
		       END as schema_type,
		       COUNT(t.table_name) as table_count
		FROM information_schema.schemata s
		LEFT JOIN information_schema.tables t ON s.schema_name = t.table_schema
		GROUP BY s.schema_name
		ORDER BY schema_type, s.schema_name
	`

	rows, err := dm.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schemas []map[string]interface{}
	for rows.Next() {
		var schemaName, schemaType string
		var tableCount int
		if err := rows.Scan(&schemaName, &schemaType, &tableCount); err != nil {
			continue
		}
		schemas = append(schemas, map[string]interface{}{
			"name":        schemaName,
			"type":        schemaType,
			"table_count": tableCount,
		})
	}

	return schemas, nil
}

func (dm *DatabaseManager) createProjectSchema(projectName string) error {
	// Create schema
	schemaSQL := fmt.Sprintf(`
		-- Create schema for project %s
		CREATE SCHEMA IF NOT EXISTS %s;

		-- Create basic tables
		CREATE TABLE IF NOT EXISTS %s.users (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			email VARCHAR(255) UNIQUE NOT NULL,
			name VARCHAR(255),
			avatar_url VARCHAR(255),
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);

		CREATE TABLE IF NOT EXISTS %s.posts (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			title VARCHAR(255) NOT NULL,
			content TEXT,
			slug VARCHAR(255) UNIQUE,
			published BOOLEAN DEFAULT false,
			user_id UUID REFERENCES %s.users(id),
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);

		-- Enable RLS
		ALTER TABLE %s.users ENABLE ROW LEVEL SECURITY;
		ALTER TABLE %s.posts ENABLE ROW LEVEL SECURITY;

		-- Create policies
		DROP POLICY IF EXISTS "%s_users_policy" ON %s.users;
		CREATE POLICY "%s_users_policy" ON %s.users FOR ALL USING (true);

		DROP POLICY IF EXISTS "%s_posts_policy" ON %s.posts;
		CREATE POLICY "%s_posts_policy" ON %s.posts FOR ALL USING (true);

		-- Create views for easy API access
		CREATE OR REPLACE VIEW public.%s_users AS SELECT * FROM %s.users;
		CREATE OR REPLACE VIEW public.%s_posts AS SELECT * FROM %s.posts;
	`, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName, projectName)

	_, err := dm.db.Exec(schemaSQL)
	return err
}

func (dm *DatabaseManager) deleteProjectSchema(projectName string) error {
	// Drop views first, then schema
	dropSQL := fmt.Sprintf(`
		DROP VIEW IF EXISTS public.%s_users CASCADE;
		DROP VIEW IF EXISTS public.%s_posts CASCADE;
		DROP SCHEMA IF EXISTS %s CASCADE;
	`, projectName, projectName, projectName)

	_, err := dm.db.Exec(dropSQL)
	return err
}

func (dm *DatabaseManager) getTablesInSchema(schemaName string) ([]string, error) {
	query := `
		SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = $1 
		ORDER BY table_name
	`

	rows, err := dm.db.Query(query, schemaName)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tables []string
	for rows.Next() {
		var tableName string
		if err := rows.Scan(&tableName); err != nil {
			continue
		}
		tables = append(tables, tableName)
	}

	return tables, nil
}

func (dm *DatabaseManager) executeQueryInProject(query string) (interface{}, error) {
	rows, err := dm.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Get column names
	columns, err := rows.Columns()
	if err != nil {
		return nil, err
	}

	// Prepare result
	var results []map[string]interface{}

	for rows.Next() {
		// Create slice for scan
		values := make([]interface{}, len(columns))
		valuePtrs := make([]interface{}, len(columns))
		for i := range values {
			valuePtrs[i] = &values[i]
		}

		if err := rows.Scan(valuePtrs...); err != nil {
			continue
		}

		// Convert to map
		row := make(map[string]interface{})
		for i, col := range columns {
			row[col] = values[i]
		}
		results = append(results, row)
	}

	return results, nil
}

func (dm *DatabaseManager) getDockerStatus() map[string]interface{} {
	cmd := exec.Command("docker-compose", "ps", "--format", "json")
	output, err := cmd.Output()

	status := map[string]interface{}{
		"running":  false,
		"services": []string{},
		"error":    nil,
	}

	if err != nil {
		status["error"] = err.Error()
		return status
	}

	// Parse docker-compose ps output
	lines := strings.Split(string(output), "\n")
	var services []string

	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}

		var service map[string]interface{}
		if err := json.Unmarshal([]byte(line), &service); err == nil {
			if name, ok := service["Name"].(string); ok {
				services = append(services, name)
			}
		}
	}

	status["services"] = services
	status["running"] = len(services) > 0

	return status
}

func isValidProjectName(name string) bool {
	if len(name) < 2 || len(name) > 30 {
		return false
	}

	for _, char := range name {
		if !((char >= 'a' && char <= 'z') ||
			(char >= '0' && char <= '9') ||
			char == '_') {
			return false
		}
	}

	return true
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// createAuthMiddleware creates a basic authentication middleware
func createAuthMiddleware(username, password string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Skip authentication for login page
		if c.Request.URL.Path == "/login" {
			c.Next()
			return
		}

		// Check for existing session
		session, err := c.Cookie("session")
		if err == nil && session == "authenticated" {
			c.Next()
			return
		}

		// Check for basic auth
		user, pass, ok := c.Request.BasicAuth()
		if ok && user == username && pass == password {
			// Set cookie for session management
			c.SetCookie("session", "authenticated", 3600, "/", "", false, true)
			c.Next()
			return
		}

		// Redirect to login page for HTML requests
		if strings.Contains(c.GetHeader("Accept"), "text/html") {
			c.Redirect(http.StatusFound, "/login")
			c.Abort()
			return
		}

		// For API requests, return 401
		c.Header("WWW-Authenticate", `Basic realm="Supabase Manager"`)
		c.AbortWithStatus(http.StatusUnauthorized)
	}
}

// loginHandler handles login requests
func loginHandler(c *gin.Context) {
	// For GET requests, show login form
	if c.Request.Method == "GET" {
		c.HTML(http.StatusOK, "login.html", gin.H{
			"title": "Login - Supabase Manager",
		})
		return
	}

	// For POST requests, process login
	username := c.PostForm("username")
	password := c.PostForm("password")

	// Load config to get credentials
	config, err := loadConfig()
	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{"error": "Failed to load configuration"})
		return
	}

	// Check credentials
	if username == config.Auth.Username && password == config.Auth.Password {
		// Set session cookie
		c.SetCookie("session", "authenticated", 3600, "/", "", false, true)
		// Redirect to dashboard
		c.Redirect(http.StatusFound, "/")
		return
	}

	// Invalid credentials
	c.HTML(http.StatusUnauthorized, "login.html", gin.H{
		"error": "Invalid username or password",
	})
}
