package com.realestate.controller;

import com.realestate.entity.MaintenanceRequest;
import com.realestate.service.MaintenanceService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/maintenance")
@CrossOrigin(origins = "*")
public class MaintenanceController {

    private final MaintenanceService maintenanceService;

    public MaintenanceController(MaintenanceService maintenanceService) {
        this.maintenanceService = maintenanceService;
    }

    @GetMapping
    public ResponseEntity<List<MaintenanceRequest>> getAllRequests(
            @RequestParam(required = false) MaintenanceRequest.RequestStatus status,
            @RequestParam(required = false) Integer propertyId) {
        if (propertyId != null) {
            return ResponseEntity.ok(maintenanceService.getRequestsByProperty(propertyId));
        }
        if (status != null) {
            return ResponseEntity.ok(maintenanceService.getRequestsByStatus(status));
        }
        return ResponseEntity.ok(maintenanceService.getAllRequests());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MaintenanceRequest> getRequestById(@PathVariable Integer id) {
        return maintenanceService.getRequestById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<MaintenanceRequest> createRequest(@RequestBody MaintenanceRequest request) {
        return ResponseEntity.ok(maintenanceService.saveRequest(request));
    }
}
