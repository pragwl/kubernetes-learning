package io.github.kuberneteslearning.service;

import io.github.kuberneteslearning.entity.Message;
import io.github.kuberneteslearning.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;

    /**
     * Stores the message in the database.
     * @param message Message entity to store
     * @return Stored Message entity
     * @throws RuntimeException if save fails
     */
    public Message storeMessage(Message message) {
        try {
            return messageRepository.save(message);
        } catch (Exception e) {
            throw new RuntimeException("Error saving message: " + e.getMessage(), e);
        }
    }
}
