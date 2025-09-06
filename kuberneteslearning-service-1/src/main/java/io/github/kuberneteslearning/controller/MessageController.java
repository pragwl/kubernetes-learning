package io.github.kuberneteslearning.controller;

import io.github.kuberneteslearning.entity.Message;
import io.github.kuberneteslearning.service.MessageService;
import io.github.kuberneteslearning.service.StatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/message")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;
    private final StatusService statusService;

    @PostMapping
    public ResponseEntity<Void> storeMessage(@RequestBody Message message) {
        try {
            Message savedMessage = messageService.storeMessage(message);
            return ResponseEntity.status(HttpStatus.CREATED).header(
                    "messageId", String.valueOf(savedMessage.getId()))
                    .header("podName", String.valueOf(statusService.getStatus().get("podName")))
                    .header("namespace", String.valueOf(statusService.getStatus().get("namespace")))
                    .header("nodeName", String.valueOf(statusService.getStatus().get("nodeName")))
                    .header("podIP", String.valueOf(statusService.getStatus().get("podIP")))
                    .header("hostIP", String.valueOf(statusService.getStatus().get("hostIP"))).build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
