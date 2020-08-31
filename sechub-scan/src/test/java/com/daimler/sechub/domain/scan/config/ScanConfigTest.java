// SPDX-License-Identifier: MIT
package com.daimler.sechub.domain.scan.config;

import static org.junit.Assert.*;

import java.util.List;

import org.junit.Test;

import com.daimler.sechub.domain.scan.ScanDomainTestFileSupport;

public class ScanConfigTest {

	@Test
	public void emptyJson_is_accepted() {
		/* prepare */
		String json = "{}";

		/* execute */
		ScanConfig config = ScanConfig.createFromJSON(json);

		/* test */
		assertNotNull(config);
		assertNull(config.getNamePatternMappings().get("xyz"));
	}

	@Test
	public void can_create_json_example1_and_has_expected_namePatternMappings() {
		/* prepare */
		String json = ScanDomainTestFileSupport.getTestfileSupport().loadTestFile("scan_config/test_scan_config1.json");

		/* execute */
		ScanConfig config = ScanConfig.createFromJSON(json);

		/* test */
		List<NamePatternToIdEntry> ab = config.getNamePatternMappings().get("someproduct.a.b");
		assertNotNull(ab);
		assertEquals(3, ab.size());

		List<NamePatternToIdEntry> cd = config.getNamePatternMappings().get("someproduct.c.d");
		assertNotNull(cd);
		assertEquals(3, ab.size());

	}

	@Test
	public void can_create_json_example1_and_providers() {
		/* prepare */
		String json = ScanDomainTestFileSupport.getTestfileSupport().loadTestFile("scan_config/test_scan_config1.json");

		/* execute */
		ScanConfig config = ScanConfig.createFromJSON(json);

		/* test */
		List<NamePatternToIdEntry> ab = config.getNamePatternMappings().get("someproduct.a.b");
		assertNotNull(ab);
		assertEquals(3, ab.size());

		List<NamePatternToIdEntry> cd = config.getNamePatternMappings().get("someproduct.c.d");
		assertNotNull(cd);
		assertEquals(3, ab.size());

	}

}
