package io.github.kuberneteslearning.service;

import io.github.kuberneteslearning.entity.Message;
import io.github.kuberneteslearning.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;

    /**
     * Fetches all messages from the database and attaches the current pod name to each.
     */
    public List<Message> getAllMessages() {
        List<Message> messages = messageRepository.findAll();
        return messages;
    }
}
