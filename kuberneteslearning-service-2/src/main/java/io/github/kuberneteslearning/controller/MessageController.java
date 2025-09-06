package io.github.kuberneteslearning.controller;

import io.github.kuberneteslearning.entity.Message;
import io.github.kuberneteslearning.service.MessageService;
import io.github.kuberneteslearning.service.StatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/message")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;
    private final StatusService statusService;

    @GetMapping
    public ResponseEntity<List<Message>> getAllMessages() {
        try {
            List<Message> existingMessages = messageService.getAllMessages();

            // Fetch Kubernetes info
            Map<String, Object> podInfo = statusService.getStatus();

            return ResponseEntity.ok()
                    .header("podName", String.valueOf(podInfo.get("podName")))
                    .header("namespace", String.valueOf(podInfo.get("namespace")))
                    .header("nodeName", String.valueOf(podInfo.get("nodeName")))
                    .header("podIP", String.valueOf(podInfo.get("podIP")))
                    .header("hostIP", String.valueOf(podInfo.get("hostIP")))
                    .body(existingMessages);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
