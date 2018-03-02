package com.github.samdaniel.tcs.microservices.uniqueid.grpc;


import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.opentracing.Scope;
import io.opentracing.Span;

import java.io.IOException;
import java.util.concurrent.Executors;

import com.github.samdaniel.tcs.microservices.uniqueid.core.InMemoryUniqueIdProvider;
import com.github.samdaniel.tcs.microservices.uniqueid.core.Tracer;


public class UniqueIdServer {
	private Server server;
	private int port;
	
	public UniqueIdServer(int port) {
		this(ServerBuilder.forPort(port));
		this.port = port;
	}
	
	private UniqueIdServer(ServerBuilder<?> serverBuilder) {
		server = serverBuilder.addService(new UniqueIdServiceImpl(new InMemoryUniqueIdProvider()))
				.executor( Executors.newSingleThreadExecutor())
				.build();
	}
	
	public void start() throws IOException, InterruptedException {
		io.opentracing.Tracer tracer = Tracer.tracer();
		Span span = tracer.buildSpan("Starting the server on port " + String.valueOf(port)).start();
		Scope s = tracer.scopeManager().activate(span, false);
		
		server.start();
		
		server.awaitTermination();
		
		s.span().log("Server started successfully on port " + String.valueOf(port));
		
		s.span().finish();
	}
	
	public void shutdownNow() {
		server.shutdownNow();
	}

}
