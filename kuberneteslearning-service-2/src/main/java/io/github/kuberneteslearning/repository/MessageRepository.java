package io.github.kuberneteslearning.repository;

import io.github.kuberneteslearning.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageRepository extends JpaRepository<Message, Long> {
}
