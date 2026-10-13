package com.realestate.repository;

import com.realestate.entity.RentPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RentPaymentRepository extends JpaRepository<RentPayment, Integer> {
    List<RentPayment> findByRentalAgreementAgreementId(Integer agreementId);
    List<RentPayment> findByStatus(RentPayment.PaymentStatus status);
}
