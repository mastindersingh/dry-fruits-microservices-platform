package com.dryfruits.platform.paymentservice.repository;

import com.dryfruits.platform.paymentservice.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    
    List<Payment> findByUserId(Long userId);
    
    Optional<Payment> findByOrderId(Long orderId);
    
    List<Payment> findByStatus(Payment.PaymentStatus status);
    
    Optional<Payment> findByTransactionId(String transactionId);
}
