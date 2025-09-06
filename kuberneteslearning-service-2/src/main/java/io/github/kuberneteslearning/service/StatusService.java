package io.github.kuberneteslearning.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * Provides combined database and Kubernetes pod status in a single response.
 */
@Service
@RequiredArgsConstructor
public class StatusService {

    private final DataSource dataSource;
    /**
     * Returns a unified status map containing:
     * - Database connectivity and metadata
     * - Simple write test results
     * - List of tables
     * - Kubernetes pod info from environment variables
     */
    public Map<String, Object> getStatus() {
        Map<String, Object> status = new HashMap<>();

        // --------- Kubernetes Pod Info ---------
        status.put("podName", System.getenv("POD_NAME"));
        status.put("namespace", System.getenv("POD_NAMESPACE"));
        status.put("nodeName", System.getenv("NODE_NAME"));
        status.put("podIP", System.getenv("POD_IP"));
        status.put("hostIP", System.getenv("HOST_IP"));

        // --------- Database Info ---------
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();

            status.put("dbConnected", true);
            status.put("dbProduct", metaData.getDatabaseProductName());
            status.put("dbVersion", metaData.getDatabaseProductVersion());
            status.put("driver", metaData.getDriverName());
            status.put("jdbcUrl", metaData.getURL());
            status.put("dbUser", metaData.getUserName());
        } catch (SQLException e) {
            status.put("dbConnected", false);
            status.put("dbError", e.getMessage());
        }

        return status;
    }
}
