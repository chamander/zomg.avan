import Foundation
import Nimble
import Quick

@testable import Zomavan

final class AbbotsfordRestaurantListProviderTests: QuickSpec {

    override func spec() {

        describe("an Abbotsford Restaurant List Provider") {

            var subject: ZomatoRestaurantListProvider!
            var requestSpy: RequestSpy!

            afterEach {
                subject = nil
                requestSpy = nil
            }

            beforeEach {
                requestSpy = RequestSpy()
                subject = ZomatoRestaurantListProvider(requestServicing: requestSpy)
            }

            it("provides the correct URL to hit") {
                subject.withRestaurantList(forSubzoneID: "98284") { _ in () }
                expect(requestSpy.requests.last?.url.absoluteString).to(equal("https://developers.zomato.com/api/v2.1/location_details"))
                expect(requestSpy.requests.last?.queryItems).to(contain(
                    [
                        URLQueryItem(name: "entity_id", value: "98284"),
                        URLQueryItem(name: "entity_type", value: "subzone")
                    ]
                ))
            }

            it("requests a maximum of ten restaurants") {
                subject.withRestaurantList(forSubzoneID: "") { _ in () }
                expect(requestSpy.requests.last?.queryItems).to(contain(URLQueryItem(name: "count", value: "10")))
            }

            it("correctly parses data in the correct format") {

                var resultantRestaurants: [Restaurant]?

                requestSpy.stubbedResult = .success((data: StubData.restaurantListJSONData, response: .stubbedSuccess()))
                subject.withRestaurantList(forSubzoneID: "") { result in
                    if case let .success(list) = result {
                        resultantRestaurants = list
                    }
                }
                expect(resultantRestaurants).toEventually(equal(
                    [
                        Restaurant(
                            identifier: "16582069",
                            name: "Jinda Thai Restaurant",
                            address: "7 Ferguson Street, Abbotsford, Melbourne",
                            imageURL: URL(string: "https://www.zomato.com")!),
                        Restaurant(
                            identifier: "18494999",
                            name: "Au79",
                            address: "27-29 Nicholson Street, Abbotsford, Melbourne",
                            imageURL: URL(string: "https://www.zomato.com")!),
                    ]
                ))
            }
        }
    }

    private struct StubData {

        static let restaurantListJSON: String =
"""
{
    "best_rated_restaurant": [
        {
            "restaurant": {
                "id": "16582069",
                "name": "Jinda Thai Restaurant",
                "location": {
                    "address": "7 Ferguson Street, Abbotsford, Melbourne"
                },
                "thumb": "https://www.zomato.com"
            }
        },
        {
            "restaurant": {
                "id": "18494999",
                "name": "Au79",
                "location": {
                    "address": "27-29 Nicholson Street, Abbotsford, Melbourne"
                },
                "thumb": "https://www.zomato.com"
            }
        }
    ]
}
"""

        static var restaurantListJSONData: Data {
            return restaurantListJSON.data(using: .utf8)!
        }
    }
}
