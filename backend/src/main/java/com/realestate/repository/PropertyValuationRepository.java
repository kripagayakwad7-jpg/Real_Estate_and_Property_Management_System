package com.realestate.repository;

import com.realestate.entity.PropertyValuation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PropertyValuationRepository extends JpaRepository<PropertyValuation, Integer> {
    List<PropertyValuation> findByPropertyPropertyIdOrderByValuationDateDesc(Integer propertyId);
}
