Feature: GraphQL introspection support

  @createSchema
  Scenario: Execute an empty GraphQL query
    When I send a "GET" request to "/graphql"
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "errors[0].extensions.status" should be equal to 400
    And the JSON node "errors[0].extensions.category" should be equal to user
    And the JSON node "errors[0].message" should be equal to "GraphQL query is not valid."

  Scenario: Introspect the GraphQL schema
    When I send the query to introspect the schema
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.__schema.types" should exist
    And the JSON node "data.__schema.queryType.name" should be equal to "Query"
    And the JSON node "data.__schema.mutationType.name" should be equal to "Mutation"

  Scenario: Introspect types
    When I send the following GraphQL request:
    """
    {
      type1: __type(name: "DummyProduct") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      type2: __type(name: "DummyAggregateOfferCursorConnection") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      type3: __type(name: "DummyAggregateOfferEdge") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.type1.description" should be equal to "Dummy Product."
    And the JSON node "data.type1.fields" should contain:
    """
    {
      "name":"offers",
      "type":{
        "name":"DummyAggregateOfferCursorConnection",
        "kind":"OBJECT",
        "ofType":null
      }
    }
    """
    And the JSON node "data.type2.fields" should contain:
    """
    {
      "name":"edges",
      "type":{
        "name":null,
        "kind":"LIST",
        "ofType":{
          "name":"DummyAggregateOfferEdge",
          "kind":"OBJECT"
        }
      }
    }
    """
    And the JSON node "data.type3.fields" should contain:
    """
    {
      "name":"node",
      "type":{
        "name":"DummyAggregateOffer",
        "kind":"OBJECT",
        "ofType":null
      }
    }
    """
    And the JSON node "data.type3.fields" should contain:
    """
    {
      "name":"cursor",
      "type":{
        "name":null,
        "kind":"NON_NULL",
        "ofType":{
          "name":"String",
          "kind":"SCALAR"
        }
      }
    }
    """

  Scenario: Introspect types with different serialization groups for item_query and collection_query
    When I send the following GraphQL request:
    """
    {
      type1: __type(name: "DummyDifferentGraphQlSerializationGroupCollection") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      type2: __type(name: "DummyDifferentGraphQlSerializationGroupItem") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.type1.description" should be equal to "Dummy with different serialization groups for item_query and collection_query."
    And the JSON node "data.type1.fields[3].name" should not exist
    And the JSON node "data.type2.fields[3].name" should be equal to "title"

  Scenario: Introspect deprecated queries
    When I send the following GraphQL request:
    """
    {
      __type (name: "Query") {
        name
        fields(includeDeprecated: true) {
          name
          isDeprecated
          deprecationReason
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the GraphQL field "deprecatedResource" is deprecated for the reason "This resource is deprecated"
    And the GraphQL field "deprecatedResources" is deprecated for the reason "This resource is deprecated"

  Scenario: Introspect deprecated mutations
    When I send the following GraphQL request:
    """
    {
      __type (name: "Mutation") {
        name
        fields(includeDeprecated: true) {
          name
          isDeprecated
          deprecationReason
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the GraphQL field "deleteDeprecatedResource" is deprecated for the reason "This resource is deprecated"
    And the GraphQL field "updateDeprecatedResource" is deprecated for the reason "This resource is deprecated"
    And the GraphQL field "createDeprecatedResource" is deprecated for the reason "This resource is deprecated"

  Scenario: Introspect a deprecated field
    When I send the following GraphQL request:
    """
    {
      __type(name: "DeprecatedResource") {
        fields(includeDeprecated: true) {
          name
          isDeprecated
          deprecationReason
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the GraphQL field "deprecatedField" is deprecated for the reason "This field is deprecated"

  Scenario: Retrieve the Relay's node interface
    When I send the following GraphQL request:
    """
    {
      __type(name: "Node") {
        name
        kind
        fields {
          name
          type {
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON should be equal to:
    """
    {
      "data": {
        "__type": {
          "name": "Node",
          "kind": "INTERFACE",
          "fields": [
            {
              "name": "id",
              "type": {
                "kind": "NON_NULL",
                "ofType": {
                  "name": "ID",
                  "kind": "SCALAR"
                }
              }
            }
          ]
        }
      }
    }
    """

  Scenario: Retrieve the Relay's node field
    When I send the following GraphQL request:
    """
    {
      __schema {
        queryType {
          fields {
            name
            type {
              name
              kind
            }
            args {
              name
              type {
                kind
                ofType {
                  name
                  kind
                }
              }
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.__schema.queryType.fields[0].name" should be equal to "node"
    And the JSON node "data.__schema.queryType.fields[0].type.name" should be equal to "Node"
    And the JSON node "data.__schema.queryType.fields[0].type.kind" should be equal to "INTERFACE"
    And the JSON node "data.__schema.queryType.fields[0].args[0].name" should be equal to "id"
    And the JSON node "data.__schema.queryType.fields[0].args[0].type.kind" should be equal to "NON_NULL"
    And the JSON node "data.__schema.queryType.fields[0].args[0].type.ofType.name" should be equal to "ID"
    And the JSON node "data.__schema.queryType.fields[0].args[0].type.ofType.kind" should be equal to "SCALAR"

  Scenario: Introspect an Iterable type field
    When I send the following GraphQL request:
    """
    {
      __type(name: "Dummy") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.__type.fields" should contain:
    """
    {
      "name":"jsonData",
      "type":{
        "name":"Iterable",
        "kind":"SCALAR",
        "ofType":null
      }
    }
    """

  Scenario: Retrieve entity - using serialization groups - fields
    When I send the following GraphQL request:
    """
    {
      typeQuery: __type(name: "DummyGroup") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      typeCreateInput: __type(name: "createDummyGroupInput") {
        description,
        inputFields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      typeCreatePayload: __type(name: "createDummyGroupPayload") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      typeCreatePayloadData: __type(name: "createDummyGroupPayloadData") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.typeQuery.fields" should have 2 elements
    And the JSON node "data.typeQuery.fields[0].name" should be equal to "id"
    And the JSON node "data.typeQuery.fields[1].name" should be equal to "foo"
    And the JSON node "data.typeCreateInput.inputFields" should have 3 elements
    And the JSON node "data.typeCreateInput.inputFields[0].name" should be equal to "bar"
    And the JSON node "data.typeCreateInput.inputFields[1].name" should be equal to "baz"
    And the JSON node "data.typeCreateInput.inputFields[2].name" should be equal to "clientMutationId"
    And the JSON node "data.typeCreatePayload.fields" should have 2 elements
    And the JSON node "data.typeCreatePayload.fields[0].name" should be equal to "dummyGroup"
    And the JSON node "data.typeCreatePayload.fields[0].type.name" should be equal to "createDummyGroupPayloadData"
    And the JSON node "data.typeCreatePayload.fields[1].name" should be equal to "clientMutationId"
    And the JSON node "data.typeCreatePayloadData.fields" should have 2 elements
    And the JSON node "data.typeCreatePayloadData.fields[0].name" should be equal to "id"
    And the JSON node "data.typeCreatePayloadData.fields[1].name" should be equal to "bar"

  Scenario: Retrieve nested mutation payload data fields
    When I send the following GraphQL request:
    """
    {
      typeCreatePayload: __type(name: "createDummyPropertyPayload") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      typeCreatePayloadData: __type(name: "createDummyPropertyPayloadData") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
      typeCreateNestedPayload: __type(name: "createDummyGroupNestedPayload") {
        description,
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.typeCreatePayload.fields" should be equal to:
    """
    [
      {
        "name":"dummyProperty",
        "type":{
          "name":"createDummyPropertyPayloadData",
          "kind":"OBJECT",
          "ofType":null
        }
      },
      {
        "name":"clientMutationId",
        "type":{
          "name":"String",
          "kind":"SCALAR",
          "ofType":null
        }
      }
    ]
    """
    And the JSON node "data.typeCreatePayloadData.fields" should contain:
    """
    {
      "name":"group",
      "type":{
        "name":"createDummyGroupNestedPayload",
        "kind":"OBJECT",
        "ofType":null
      }
    }
    """
    And the JSON node "data.typeCreateNestedPayload.fields" should contain:
    """
    {
      "name":"id",
      "type":{
        "name":null,
        "kind":"NON_NULL",
        "ofType":{
          "name":"ID",
          "kind":"SCALAR"
        }
      }
    }
    """

  Scenario: Retrieve a type name through a GraphQL query
    Given there are 4 dummy objects with relatedDummy
    When I send the following GraphQL request:
    """
    {
      dummy: dummy(id: "/dummies/3") {
        name
        relatedDummy {
          id
          name
          __typename
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "data.dummy.name" should be equal to "Dummy #3"
    And the JSON node "data.dummy.relatedDummy.name" should be equal to "RelatedDummy #3"
    And the JSON node "data.dummy.relatedDummy.__typename" should be equal to "RelatedDummy"

  Scenario: Introspect a type available only through relations
    When I send the following GraphQL request:
    """
    {
      typeNotAvailable: __type(name: "VoDummyInspectionCursorConnection") {
        description
      }
      typeOwner: __type(name: "VoDummyCar") {
        description,
        fields {
          name
          type {
            name
          }
        }
      }
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "errors[0].debugMessage" should be equal to 'Type with id "VoDummyInspectionCursorConnection" is not present in the types container'
    And the JSON node "data.typeNotAvailable" should be null
    And the JSON node "data.typeOwner.fields[1].type.name" should be equal to "VoDummyInspectionCursorConnection"
