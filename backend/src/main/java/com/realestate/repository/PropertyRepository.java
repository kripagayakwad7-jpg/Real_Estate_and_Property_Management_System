package com.realestate.repository;

import com.realestate.entity.Property;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PropertyRepository extends JpaRepository<Property, Integer> {
    List<Property> findByStatus(Property.PropertyStatus status);
    List<Property> findByCityIgnoreCase(String city);
    List<Property> findByOwnerOwnerId(Integer ownerId);
}
