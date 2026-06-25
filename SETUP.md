# School Management App — Setup Guide

## Flutter Frontend Setup (VS Code)

### Step 1: Prerequisites
```bash
# Install Flutter SDK
https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Install VS Code Extensions:
# - Flutter (by Dart Code)
# - Dart (by Dart Code)
# - Flutter Widget Snippets
```

### Step 2: Create Project
```bash
flutter create school_management_app
cd school_management_app

# Copy all provided lib/ files into the project
# Then install dependencies:
flutter pub get
```

### Step 3: Run the App
```bash
# Chrome (Web)
flutter run -d chrome

# Android (connect device or start emulator)
flutter run -d android

# Windows Desktop
flutter run -d windows
```

---

## Go Backend Setup

### Step 1: Install Go
```bash
https://go.dev/dl/
# Verify
go version
```

### Step 2: Create Backend
```bash
mkdir school_backend && cd school_backend
go mod init school_backend

# Install dependencies
go get github.com/gin-gonic/gin
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/golang-jwt/jwt/v5
go get github.com/joho/godotenv
```

### Step 3: main.go (Go Backend Entry Point)
```go
package main

import (
    "log"
    "os"

    "github.com/gin-gonic/gin"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

var DB *gorm.DB

func main() {
    // Database connection
    dsn := "host=localhost user=postgres password=password dbname=school_db port=5432"
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        log.Fatal("Failed to connect to database:", err)
    }
    DB = db

    // Auto migrate tables
    DB.AutoMigrate(&User{}, &Student{}, &Staff{}, &Class{},
        &Subject{}, &Attendance{}, &Fee{}, &Exam{}, &Marks{},
        &Notice{}, &Timetable{})

    // Setup Gin router
    r := gin.Default()

    // CORS middleware
    r.Use(func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", "*")
        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        c.Next()
    })

    // Routes
    api := r.Group("/api/v1")
    {
        // Auth (no JWT required)
        api.POST("/auth/login", Login)
        api.POST("/auth/register", Register)

        // Protected routes
        protected := api.Group("/")
        protected.Use(JWTMiddleware())
        {
            protected.GET("/auth/me", GetMe)
            protected.POST("/auth/logout", Logout)

            // Students
            protected.GET("/students", GetStudents)
            protected.POST("/students", CreateStudent)
            protected.GET("/students/:id", GetStudentByID)
            protected.PUT("/students/:id", UpdateStudent)
            protected.DELETE("/students/:id", DeleteStudent)

            // Attendance
            protected.GET("/attendance", GetAttendance)
            protected.POST("/attendance", MarkAttendance)

            // Fees
            protected.GET("/fees", GetFees)
            protected.POST("/fees", CreateFee)

            // Exams
            protected.GET("/exams", GetExams)
            protected.POST("/exams", CreateExam)
            protected.GET("/marks/student/:id", GetMarksByStudent)

            // Notices
            protected.GET("/notices", GetNotices)
            protected.POST("/notices", CreateNotice)
        }
    }

    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    log.Println("Server running on port", port)
    r.Run(":" + port)
}
```

### Step 4: JWT Middleware (middleware/jwt.go)
```go
package main

import (
    "net/http"
    "strings"

    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"
)

var jwtSecret = []byte("your_jwt_secret_key_here")

func JWTMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
            c.JSON(http.StatusUnauthorized, gin.H{"message": "Authorization required"})
            c.Abort()
            return
        }

        tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
        token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
            return jwtSecret, nil
        })

        if err != nil || !token.Valid {
            c.JSON(http.StatusUnauthorized, gin.H{"message": "Invalid token"})
            c.Abort()
            return
        }

        claims := token.Claims.(jwt.MapClaims)
        c.Set("user_id", claims["user_id"])
        c.Set("role", claims["role"])
        c.Next()
    }
}
```

### Step 5: Run Backend
```bash
go run main.go
# Server starts at http://localhost:8080
```

---

## Database Schema (PostgreSQL)
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'student',
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    admission_no VARCHAR(50) UNIQUE NOT NULL,
    class_id INTEGER,
    section VARCHAR(10),
    dob DATE,
    gender VARCHAR(10),
    phone VARCHAR(20),
    parent_name VARCHAR(255),
    parent_phone VARCHAR(20),
    address TEXT,
    photo_url TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE staffs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    employee_id VARCHAR(50) UNIQUE,
    name VARCHAR(255),
    designation VARCHAR(100),
    department VARCHAR(100),
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE classes (
    id SERIAL PRIMARY KEY,
    class_name VARCHAR(50),
    section VARCHAR(10),
    academic_year VARCHAR(20)
);

CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    class_id INTEGER REFERENCES classes(id),
    subject_name VARCHAR(100),
    subject_code VARCHAR(20)
);

CREATE TABLE attendance (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    class_id INTEGER REFERENCES classes(id),
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'present',
    period VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE fees (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    fee_type VARCHAR(100),
    amount DECIMAL(10,2),
    paid_amount DECIMAL(10,2) DEFAULT 0,
    due_date DATE,
    paid_date DATE,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    exam_name VARCHAR(255),
    class_id INTEGER REFERENCES classes(id),
    start_date DATE,
    end_date DATE
);

CREATE TABLE marks (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    exam_id INTEGER REFERENCES exams(id),
    subject_id INTEGER REFERENCES subjects(id),
    marks_obtained DECIMAL(5,2)
);

CREATE TABLE notices (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    date DATE,
    created_by INTEGER REFERENCES users(id),
    target_role VARCHAR(50) DEFAULT 'all'
);
```

---

## Folder Structure in VS Code

```
school_management_app/          ← Flutter root (open this in VS Code)
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── config/api_constants.dart
│   │   └── theme/app_theme.dart
│   ├── models/student_model.dart
│   ├── services/api_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── student_provider.dart
│   ├── routes/app_router.dart
│   └── views/
│       ├── auth/login_screen.dart
│       ├── dashboard/admin_dashboard.dart
│       ├── students/student_list_screen.dart
│       └── attendance/mark_attendance_screen.dart
├── pubspec.yaml
└── assets/

school_backend/                 ← Go backend (open separately)
├── main.go
├── go.mod
└── go.sum
```
