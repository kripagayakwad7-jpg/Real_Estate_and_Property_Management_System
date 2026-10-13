package com.realestate.service;

import com.realestate.entity.MaintenanceRequest;
import com.realestate.repository.MaintenanceRequestRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class MaintenanceService {

    private final MaintenanceRequestRepository maintenanceRequestRepository;

    public MaintenanceService(MaintenanceRequestRepository maintenanceRequestRepository) {
        this.maintenanceRequestRepository = maintenanceRequestRepository;
    }

    public List<MaintenanceRequest> getAllRequests() {
        return maintenanceRequestRepository.findAll();
    }

    public Optional<MaintenanceRequest> getRequestById(Integer id) {
        return maintenanceRequestRepository.findById(id);
    }

    public List<MaintenanceRequest> getRequestsByProperty(Integer propertyId) {
        return maintenanceRequestRepository.findByPropertyPropertyId(propertyId);
    }

    public List<MaintenanceRequest> getRequestsByStatus(MaintenanceRequest.RequestStatus status) {
        return maintenanceRequestRepository.findByStatus(status);
    }

    @Transactional
    public MaintenanceRequest saveRequest(MaintenanceRequest request) {
        return maintenanceRequestRepository.save(request);
    }
}
