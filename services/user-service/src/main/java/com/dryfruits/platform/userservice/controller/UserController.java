package com.dryfruits.platform.userservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class UserController {

    @GetMapping("/")
    public Map<String, Object> root() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "User Service");
        response.put("description", "Dry Fruits Platform - User Management & Authentication API");
        response.put("version", "1.0.0");
        response.put("status", "UP");
        response.put("endpoints", new String[]{
            "/api/v1/auth/register - Register new user",
            "/api/v1/auth/login - User login",
            "/api/v1/users/health - Health check",
            "/api/v1/users/info - Service information",
            "/actuator/health - Actuator health"
        });
        return response;
    }

    @GetMapping("/api/v1/users/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "user-service");
        response.put("status", "UP");
        response.put("timestamp", System.currentTimeMillis());
        response.put("message", "User Service is running successfully!");
        return response;
    }

    @GetMapping("/api/v1/users/info")
    public Map<String, Object> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "user-service");
        response.put("version", "1.0.0");
        response.put("description", "Dry Fruits Platform - User Management Service");
        response.put("features", new String[]{"User Registration", "Authentication", "Profile Management"});
        return response;
    }
}