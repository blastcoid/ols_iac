# app/internal/adapter/transport/graphql/profile_router.py

import strawberry
from fastapi import Request
from strawberry.fastapi import GraphQLRouter
from ....application.graphql.profile_resolver import Context, ProfileQuery, ProfileMutation

async def get_context(request: Request) -> Context:
    return Context(request)

schema = strawberry.Schema(query=ProfileQuery, mutation=ProfileMutation)
profile_gql_router = GraphQLRouter(schema, path="/profile-gql", debug=True, context_getter=get_context)