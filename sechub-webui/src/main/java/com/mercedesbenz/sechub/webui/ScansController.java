package com.mercedesbenz.sechub.webui;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ScansController {
	@Value("${sechub.serverUrl}")
	private String secHubServerUrl;
	
	@GetMapping("/projects/{projectId}/scans")
	String scans(Model model) {
		model.addAttribute("sechubServerUrl", secHubServerUrl);
		return "scans";
	}
}
