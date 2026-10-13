package com.realestate.service;

import com.realestate.entity.RentPayment;
import com.realestate.repository.AnalyticsRepository;
import com.realestate.repository.RentPaymentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class PaymentService {

    private final RentPaymentRepository rentPaymentRepository;
    private final AnalyticsRepository analyticsRepository;

    public PaymentService(RentPaymentRepository rentPaymentRepository,
                          AnalyticsRepository analyticsRepository) {
        this.rentPaymentRepository = rentPaymentRepository;
        this.analyticsRepository = analyticsRepository;
    }

    public List<RentPayment> getAllPayments() {
        return rentPaymentRepository.findAll();
    }

    public Optional<RentPayment> getPaymentById(Integer id) {
        return rentPaymentRepository.findById(id);
    }

    public List<RentPayment> getPaymentsByAgreement(Integer agreementId) {
        return rentPaymentRepository.findByRentalAgreementAgreementId(agreementId);
    }

    public List<RentPayment> getPaymentsByStatus(RentPayment.PaymentStatus status) {
        return rentPaymentRepository.findByStatus(status);
    }

    /**
     * Executes the MySQL stored procedure `record_rent_payment` inside transaction
     */
    @Transactional
    public Map<String, Object> recordPaymentViaProcedure(Integer agreementId,
                                                          BigDecimal amount,
                                                          LocalDate date,
                                                          String paymentMode) {
        return analyticsRepository.callRecordRentPaymentProcedure(agreementId, amount, date, paymentMode);
    }
}
