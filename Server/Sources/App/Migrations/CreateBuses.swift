import Fluent

struct CreateBuses: Migration {
	
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		return database
			.schema("buses")
			.id()
			.field("locations", .array(of: .custom(Bus.Location.self)), .required)
			.create()
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		return database
			.schema("buses")
			.delete()
	}
	
}
