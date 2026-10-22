Feature: ODA Canvas Prerequisites Installation

  Scenario: Istio repository is added
    Given I have a clean environment
    When I add the Istio Helm repository using the documented commands
    Then the Istio Helm repository should be present in the Helm repo list

  Scenario: Istio is installed
    Given the Istio Helm repository is added
    When I install Istio using the documented commands
    Then the "istio-base" and "istiod" releases should be deployed in the cluster

  Scenario: Prerequisites chart is installed
    Given Istio is installed
    When I install the prerequisites chart using the documented commands
    Then the "prerequisites" release should be deployed in the cluster

  Scenario: Keycloak is deployed in the default namespace
    Given the prerequisites chart is installed
    Then Keycloak StatefulSet should exist in namespace "keycloak"
    And Keycloak Service should be accessible in namespace "keycloak"
    And Postgres Service should exist in namespace "keycloak"

  Scenario: Keycloak is deployed in a custom namespace
    Given I have a clean environment
    When I install the prerequisites chart with custom namespace "identity-services"
    Then Keycloak StatefulSet should exist in namespace "identity-services"
    And Keycloak Service should be accessible in namespace "identity-services"
    And Postgres Service should exist in namespace "identity-services"

  Scenario: Keycloak credentials Secret exists in correct namespace
    Given the prerequisites chart is installed
    Then Keycloak credentials Secret should exist in namespace "keycloak"

  Scenario: All prerequisites are installed
    Given I have a clean environment
    When I follow all installation steps using the documented commands
    Then Istio and the prerequisites chart should all be installed
