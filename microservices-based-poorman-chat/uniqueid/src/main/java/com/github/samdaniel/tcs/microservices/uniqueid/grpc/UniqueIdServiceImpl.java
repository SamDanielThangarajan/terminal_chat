package com.github.samdaniel.tcs.microservices.uniqueid.grpc;

import com.github.samdaniel.tcs.microservices.uniqueid.core.Tracer;
import com.github.samdaniel.tcs.microservices.uniqueid.core.UniqueIdProvider;
import com.github.samdaniel.tcs.microservices.uniqueid.generated.UniqueIdServiceGrpc;
import com.github.samdaniel.tcs.microservices.uniqueid.generated.UniqueidService.UniqueIdResponse;

import io.opentracing.Scope;
import io.opentracing.Span;

import com.github.samdaniel.tcs.microservices.uniqueid.generated.UniqueidService.UniqueIdRequest;

public class UniqueIdServiceImpl extends UniqueIdServiceGrpc.UniqueIdServiceImplBase {
	
	UniqueIdProvider provider;
	
	public UniqueIdServiceImpl(UniqueIdProvider provider) {
		this.provider = provider;
	}
	
	private UniqueIdResponse getUniqueIdResponse(int requestId) {
		return UniqueIdResponse.newBuilder()
				.setRequestId(requestId)
				.setUniqueId(provider.getUniqueId().toString()).build();
	}
	
	@Override
	public void getUniqueId(UniqueIdRequest request, io.grpc.stub.StreamObserver<UniqueIdResponse> responseObserver) {
		
		io.opentracing.Tracer tracer = Tracer.tracer();
		//Span span = tracer.buildSpan("Processing getUniqueId").start();
		Scope s = tracer.buildSpan("Processing getUniqueId").startActive(true);
		//Scope s = tracer.scopeManager().activate(span, false);

		UniqueIdResponse resp = this.getUniqueIdResponse(request.getRequestId());
		
		s.span().setTag("requestId", request.getRequestId());
		s.span().setTag("uniqueId", resp.getUniqueId());
		s.span().log("Finished processing the request for " + String.valueOf(request.getRequestId()));
		
		responseObserver.onNext(resp);
		responseObserver.onCompleted();
		
		//tracer.scopeManager().
		//s.span().finish();
		//s.close();
	}
}
