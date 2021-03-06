// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "compartment_ocid" {
}

variable "region" {
}

provider "oci" {
  region           = "${var.region}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
}

// categories
data "oci_optimizer_categories" "test_categories" {
  compartment_id = "${var.tenancy_ocid}"
  compartment_id_in_subtree = "true"
}

data "oci_optimizer_category" "test_category" {
  category_id = "${lookup(data.oci_optimizer_categories.test_categories.category_collection.0.items[0], "id")}"
}

// recommendations
data "oci_optimizer_recommendations" "test_recommendations" {
  category_id = "${lookup(data.oci_optimizer_categories.test_categories.category_collection.0.items[0], "id")}"
  compartment_id = "${var.tenancy_ocid}"
  compartment_id_in_subtree = "true"
  filter {
    name   = "importance"
    values = ["HIGH"]
  }
}

resource "oci_optimizer_recommendation" "test_recommendation" {
  recommendation_id = "${data.oci_optimizer_recommendations.test_recommendations.recommendation_collection.0.items.0.id}"
  status = "PENDING"
}

data "oci_optimizer_recommendation" "test_recommendation" {
  recommendation_id = "${data.oci_optimizer_recommendations.test_recommendations.recommendation_collection.0.items.0.id}"
}

// resource action
data "oci_optimizer_resource_actions" "test_resource_actions" {
  compartment_id = "${var.tenancy_ocid}"
  compartment_id_in_subtree = "true"
  recommendation_id = "${oci_optimizer_recommendation.test_recommendation.recommendation_id}"
  filter {
    name   = "name"
    values = ["inst-host-underutilized"]
  }
}

data "oci_optimizer_resource_action" "test_resource_action" {
  resource_action_id = "${data.oci_optimizer_resource_actions.test_resource_actions.resource_action_collection.0.items.0.id}"
}

resource "oci_optimizer_resource_action" "test_resource_action" {
  resource_action_id = "${data.oci_optimizer_resource_actions.test_resource_actions.resource_action_collection.0.items.0.id}"
  status = "PENDING"
}

// profile
variable defined_tag_namespace_name { default = "example-tag-namespace-all" }

resource "oci_identity_tag_namespace" "tag-namespace1" {
  #Required
  compartment_id = "${var.tenancy_ocid}"
  description = "example tag namespace"
  name = "${var.defined_tag_namespace_name}"

  is_retired = false
}

resource "oci_identity_tag" "tag1" {
  #Required
  description = "example tag"
  name = "example-tag"
  tag_namespace_id = "${oci_identity_tag_namespace.tag-namespace1.id}"

  is_retired = false
}

resource "oci_optimizer_profile" "test_profile" {
  compartment_id = "${var.tenancy_ocid}"
  description = "description"
  levels_configuration {
    items {
      level = "cost-compute_aggressive_average"
      recommendation_id = "${oci_optimizer_recommendation.test_recommendation.recommendation_id}"
    }
  }
  name = "name"
}

data "oci_optimizer_profile" "test_profile" {
  profile_id = "${oci_optimizer_profile.test_profile.id}"
}

data "oci_optimizer_profiles" "test_profiles" {
  compartment_id = "${var.tenancy_ocid}"
  name = "name"
  state = "ACTIVE"
}

// enrollment status
data "oci_optimizer_enrollment_statuses" "test_enrollment_statuses" {
  compartment_id = "${var.tenancy_ocid}"
}

resource "oci_optimizer_enrollment_status" "test_enrollment_status" {
  enrollment_status_id = "${data.oci_optimizer_enrollment_statuses.test_enrollment_statuses.enrollment_status_collection.0.items.0.id}"
  status = "ACTIVE"
}

// histories
data "oci_optimizer_histories" "test_histories" {
  compartment_id = "${var.tenancy_ocid}"
  compartment_id_in_subtree = "true"
}