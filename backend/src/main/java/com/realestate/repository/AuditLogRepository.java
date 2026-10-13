package com.realestate.repository;

import com.realestate.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Integer> {
    List<AuditLog> findByTableNameOrderByChangedAtDesc(String tableName);
    List<AuditLog> findTop20ByOrderByChangedAtDesc();
}
