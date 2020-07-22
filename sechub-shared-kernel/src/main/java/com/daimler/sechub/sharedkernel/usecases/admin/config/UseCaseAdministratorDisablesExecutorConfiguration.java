// SPDX-License-Identifier: MIT
package com.daimler.sechub.sharedkernel.usecases.admin.config;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import com.daimler.sechub.sharedkernel.Step;
import com.daimler.sechub.sharedkernel.usecases.UseCaseDefinition;
import com.daimler.sechub.sharedkernel.usecases.UseCaseGroup;
import com.daimler.sechub.sharedkernel.usecases.UseCaseIdentifier;

/* @formatter:off */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@UseCaseDefinition(
		id=UseCaseIdentifier.UC_ADMIN_DISABLES_EXECUTOR_CONFIGURATION,
		group=UseCaseGroup.CONFIGURATION,
		title="Admin disables executor configuration",
		description="An administrator disables an existing executor configuration. So this executor will NOT be used for scanning any longer")
public @interface UseCaseAdministratorDisablesExecutorConfiguration{

	Step value();
}
/* @formatter:on */
