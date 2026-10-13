package com.realestate.controller;

import com.realestate.entity.RentPayment;
import com.realestate.service.PaymentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @GetMapping
    public ResponseEntity<List<RentPayment>> getAllPayments(
            @RequestParam(required = false) RentPayment.PaymentStatus status,
            @RequestParam(required = false) Integer agreementId) {
        if (agreementId != null) {
            return ResponseEntity.ok(paymentService.getPaymentsByAgreement(agreementId));
        }
        if (status != null) {
            return ResponseEntity.ok(paymentService.getPaymentsByStatus(status));
        }
        return ResponseEntity.ok(paymentService.getAllPayments());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RentPayment> getPaymentById(@PathVariable Integer id) {
        return paymentService.getPaymentById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Executes the MySQL Stored Procedure `record_rent_payment`
     */
    @PostMapping("/record")
    public ResponseEntity<Map<String, Object>> recordPayment(
            @RequestParam Integer agreementId,
            @RequestParam BigDecimal amount,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate paymentDate,
            @RequestParam String paymentMode) {
        Map<String, Object> result = paymentService.recordPaymentViaProcedure(agreementId, amount, paymentDate, paymentMode);
        return ResponseEntity.ok(result);
    }
}
