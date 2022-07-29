//
//  API+Test.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import Foundation

let testLaundriesV1 =
"""
{
  "code": 0,
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "Test 1",
      "photo": "https://picsum.photos/200",
      "items": [
        {
          "name": "Item 1",
          "price": 10
        },
        {
          "name": "Item 2",
          "price": 20
        }
      ]
    },
    {
      "id": 2,
      "name": "Test 2",
      "photo": "https://picsum.photos/200",
      "items": [
        {
          "name": "Item 1",
          "price": 10
        },
        {
          "name": "Item 2",
          "price": 20
        }
      ]
    },
    {
      "id": 3,
      "name": "Test 3",
      "photo": "https://picsum.photos/200",
      "items": [
        {
          "name": "Item 1",
          "price": 10
        }
      ]
    }
  ]
}
"""

let testLaundriesV2 =
"""
{
  "code": 0,
  "data": {
    "success": [
      {
        "id": 1,
        "name": "Test 1",
        "photo": "https://picsum.photos/200",
        "items": [
          {
            "name": "Item 1",
            "price": 10
          },
          {
            "name": "Item 2",
            "price": 20
          }
        ]
      },
      {
        "id": 2,
        "name": "Test 2",
        "photo": "https://picsum.photos/200",
        "items": [
          {
            "name": "Item 1",
            "price": 10
          },
          {
            "name": "Item 2",
            "price": 20
          }
        ]
      },
      {
        "id": 3,
        "name": "Test 3",
        "photo": "https://picsum.photos/200",
        "items": [
          {
            "name": "Item 1",
            "price": 10
          }
        ]
      }
    ]
  }
}
"""
