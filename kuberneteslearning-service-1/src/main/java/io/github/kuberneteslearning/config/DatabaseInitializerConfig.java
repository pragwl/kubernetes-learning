package io.github.kuberneteslearning.config;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Ensures that the target database exists at application startup.
 */
@Component
@RequiredArgsConstructor
public class DatabaseInitializerConfig {

    @Value("${spring.datasource.url}")
    private String datasourceUrl;

    @Value("${spring.datasource.username}")
    private String username;

    @Value("${spring.datasource.password}")
    private String password;

    @PostConstruct
    public void ensureDatabaseExists() {
        try {
            String dbName = extractDatabaseName(datasourceUrl);
            String adminUrl = datasourceUrl.replace(dbName, "postgres");

            try (Connection conn = DriverManager.getConnection(adminUrl, username, password);
                 Statement stmt = conn.createStatement()) {

                ResultSet rs = stmt.executeQuery("SELECT 1 FROM pg_database WHERE datname = '" + dbName + "'");
                if (!rs.next()) {
                    stmt.executeUpdate("CREATE DATABASE \"" + dbName + "\"");
                    System.out.println("✅ Database '" + dbName + "' created.");
                } else {
                    System.out.println("ℹ️ Database '" + dbName + "' already exists.");
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to check/create database: " + e.getMessage(), e);
        }
    }

    private String extractDatabaseName(String url) {
        return url.substring(url.lastIndexOf("/") + 1);
    }
}
