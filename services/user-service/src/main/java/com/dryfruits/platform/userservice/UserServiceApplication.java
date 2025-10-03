package com.dryfruits.platform.userservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
// Simplified without Eureka for now
// import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
// import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
// @EnableEurekaClient
// @EnableFeignClients
public class UserServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}