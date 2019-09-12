class User < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary32,
    name: String,
    gender: Bool,
    created_at: Time?,
    updated_at: Time?,
  )
end
