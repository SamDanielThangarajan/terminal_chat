package com.github.samdaniel.tcs.microservices.registry.grpc;

import java.io.IOException;
import java.util.concurrent.Executors;

import com.github.samdaniel.tcs.microservices.registry.config.Tracer;
import com.github.samdaniel.tcs.microservices.registry.core.InMemoryStorageClass;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.opentracing.Scope;
import io.opentracing.Span;

public class RegistryServer {
	
	private Server server;
	private int port;
	
	public RegistryServer(int port) {
		this(ServerBuilder.forPort(port));
		this.port = port;
	}
	
	private RegistryServer(ServerBuilder<?> serverBuilder) {
		server = serverBuilder.addService(new RegistryServiceImpl(new InMemoryStorageClass()))
				.executor(Executors.newSingleThreadExecutor())
				.build();
	}
	
	public void start() throws IOException, InterruptedException {
		io.opentracing.Tracer tracer = Tracer.tracer();
		Span span = tracer.buildSpan("Starting the server on port " + String.valueOf(port)).start();
		Scope s = tracer.scopeManager().activate(span, false);
		
		System.out.println("Server starting on port " + port );
		
		server.start();
		
		server.awaitTermination();
		
		s.span().log("Server started successfully on port " + String.valueOf(port));
		
		s.span().finish();
	}
	
	public void shutDownNow() {
		server.shutdownNow();
	}
}
