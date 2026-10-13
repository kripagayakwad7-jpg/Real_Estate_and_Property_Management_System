package com.realestate.repository;

import com.realestate.entity.RentalAgreement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface RentalAgreementRepository extends JpaRepository<RentalAgreement, Integer> {
    List<RentalAgreement> findByPropertyPropertyId(Integer propertyId);
    List<RentalAgreement> findByTenantTenantId(Integer tenantId);
    List<RentalAgreement> findByStatus(RentalAgreement.AgreementStatus status);
    Optional<RentalAgreement> findByPropertyPropertyIdAndStatus(Integer propertyId, RentalAgreement.AgreementStatus status);
}
