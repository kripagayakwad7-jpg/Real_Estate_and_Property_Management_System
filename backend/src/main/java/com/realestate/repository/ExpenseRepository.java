package com.realestate.repository;

import com.realestate.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Integer> {
    List<Expense> findByPropertyPropertyId(Integer propertyId);
    List<Expense> findByCategory(Expense.ExpenseCategory category);
}
