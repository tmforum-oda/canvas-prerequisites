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

  Scenario: All prerequisites are installed
    Given I have a clean environment
    When I follow all installation steps using the documented commands
    Then Istio and the prerequisites chart should all be installed
