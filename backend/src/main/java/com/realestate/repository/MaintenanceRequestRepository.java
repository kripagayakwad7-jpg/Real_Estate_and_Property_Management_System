package com.realestate.repository;

import com.realestate.entity.MaintenanceRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MaintenanceRequestRepository extends JpaRepository<MaintenanceRequest, Integer> {
    List<MaintenanceRequest> findByPropertyPropertyId(Integer propertyId);
    List<MaintenanceRequest> findByStatus(MaintenanceRequest.RequestStatus status);
}
