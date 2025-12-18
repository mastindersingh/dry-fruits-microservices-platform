package com.dryfruits.platform.paymentservice.controller;

import com.dryfruits.platform.paymentservice.dto.PaymentRequest;
import com.dryfruits.platform.paymentservice.dto.PaymentResponse;
import com.dryfruits.platform.paymentservice.model.Payment;
import com.dryfruits.platform.paymentservice.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class PaymentController {
    
    @Autowired
    private PaymentService paymentService;
    
    /**
     * Root endpoint
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, String>> root() {
        Map<String, String> response = new HashMap<>();
        response.put("service", "Payment Service");
        response.put("version", "1.0.0");
        response.put("status", "UP");
        response.put("description", "Mock Payment Gateway API");
        return ResponseEntity.ok(response);
    }
    
    /**
     * Process a payment
     */
    @PostMapping("/api/v1/payments/process")
    public ResponseEntity<?> processPayment(@Valid @RequestBody PaymentRequest request) {
        try {
            PaymentResponse response = paymentService.processPayment(request);
            
            if ("COMPLETED".equals(response.getStatus())) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(response);
            }
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Payment processing failed");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get payment by ID
     */
    @GetMapping("/api/v1/payments/{id}")
    public ResponseEntity<?> getPayment(@PathVariable Long id) {
        try {
            Payment payment = paymentService.getPaymentById(id);
            return ResponseEntity.ok(payment);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Payment not found");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }
    
    /**
     * Get payment by order ID
     */
    @GetMapping("/api/v1/payments/order/{orderId}")
    public ResponseEntity<?> getPaymentByOrder(@PathVariable Long orderId) {
        try {
            Payment payment = paymentService.getPaymentByOrderId(orderId);
            return ResponseEntity.ok(payment);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Payment not found for order");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }
    
    /**
     * Health check endpoint
     */
    @GetMapping("/api/v1/payments/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "payment-service");
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get test card numbers
     */
    @GetMapping("/api/v1/payments/test-cards")
    public ResponseEntity<Map<String, Object>> getTestCards() {
        Map<String, Object> testCards = new HashMap<>();
        testCards.put("success_cards", new String[]{
            "4111111111111111 (Visa - Always Success)",
            "5555555555554444 (Mastercard - Always Success)",
            "378282246310005 (Amex - Always Success)"
        });
        testCards.put("failure_cards", new String[]{
            "4000000000000002 (Visa - Insufficient Funds)",
            "4000000000009995 (Visa - Card Declined)"
        });
        testCards.put("test_data", Map.of(
            "cvv", "123",
            "expiry_month", "12",
            "expiry_year", "2027",
            "cardholder_name", "Test User"
        ));
        return ResponseEntity.ok(testCards);
    }
}
