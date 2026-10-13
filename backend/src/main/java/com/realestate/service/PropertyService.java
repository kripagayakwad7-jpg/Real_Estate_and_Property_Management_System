package com.realestate.service;

import com.realestate.entity.Property;
import com.realestate.repository.PropertyRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class PropertyService {

    private final PropertyRepository propertyRepository;

    public PropertyService(PropertyRepository propertyRepository) {
        this.propertyRepository = propertyRepository;
    }

    public List<Property> getAllProperties() {
        return propertyRepository.findAll();
    }

    public Optional<Property> getPropertyById(Integer id) {
        return propertyRepository.findById(id);
    }

    public List<Property> getPropertiesByStatus(Property.PropertyStatus status) {
        return propertyRepository.findByStatus(status);
    }

    public List<Property> getPropertiesByCity(String city) {
        return propertyRepository.findByCityIgnoreCase(city);
    }

    @Transactional
    public Property saveProperty(Property property) {
        return propertyRepository.save(property);
    }

    @Transactional
    public void deleteProperty(Integer id) {
        propertyRepository.deleteById(id);
    }
}
