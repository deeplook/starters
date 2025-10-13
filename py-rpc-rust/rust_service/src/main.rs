use std::env;
use std::net::SocketAddr;

use anyhow::Result;
use tonic::transport::Server;
use tonic::{Request, Response, Status};
use tonic_reflection::server::Builder as ReflectionBuilder;
use tonic_health::server::health_reporter;
use tonic_health::ServingStatus;

pub mod bridge {
    tonic::include_proto!("bridge");
}

use bridge::python_greeter_client::PythonGreeterClient;
use bridge::rust_greeter_server::{RustGreeter, RustGreeterServer};
use bridge::{HelloReply, HelloRequest};

// Used to feed the reflection service with the full protobuf descriptor set.
const FILE_DESCRIPTOR_SET: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/bridge_descriptor.bin"));

#[derive(Default)]
struct RustGreeterImpl;

#[tonic::async_trait]
impl RustGreeter for RustGreeterImpl {
    async fn say_hello(&self, request: Request<HelloRequest>) -> Result<Response<HelloReply>, Status> {
        let name = request.into_inner().name;
        let reply = HelloReply {
            message: format!("Hello, {name}! From the Rust service."),
            from_service: "rust".into(),
        };
        Ok(Response::new(reply))
    }
}

async fn run_server(addr: SocketAddr) -> Result<()> {
    println!("Starting Rust gRPC server on {addr}");
    let greeter = RustGreeterServer::new(RustGreeterImpl::default());
    let reflection = ReflectionBuilder::configure()
        .register_encoded_file_descriptor_set(FILE_DESCRIPTOR_SET)
        .build()
        .expect("reflection service");
    let (mut health_reporter, health_service) = health_reporter();
    health_reporter
        .set_service_status("", ServingStatus::Serving)
        .await;
    health_reporter
        .set_service_status("bridge.RustGreeter", ServingStatus::Serving)
        .await;

    Server::builder()
        .add_service(health_service)
        .add_service(reflection)
        .add_service(greeter)
        .serve(addr)
        .await?;
    Ok(())
}

async fn run_client(name: String, target: String) -> Result<()> {
    let endpoint = if target.starts_with("http://") || target.starts_with("https://") {
        target
    } else {
        format!("http://{target}")
    };

    let mut client = PythonGreeterClient::connect(endpoint.clone()).await?;
    let response = client
        .say_hello(Request::new(HelloRequest { name }))
        .await?
        .into_inner();

    println!(
        "Python service replied: {} (source: {})",
        response.message, response.from_service
    );

    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    let mode = env::args().nth(1).unwrap_or_else(|| "server".to_string());

    match mode.as_str() {
        "server" => {
            let host = env::var("RUST_SERVICE_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
            let port = env::var("RUST_SERVICE_PORT")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(50052);
            let addr: SocketAddr = format!("{host}:{port}").parse()?;
            run_server(addr).await?;
        }
        "client" => {
            let name = env::args().nth(2).unwrap_or_else(|| "world".to_string());
            let target = env::var("PYTHON_SERVICE_ADDR").unwrap_or_else(|_| "http://127.0.0.1:50051".to_string());
            run_client(name, target).await?;
        }
        other => {
            eprintln!(
                "Unrecognised mode '{other}'. Use 'server' (default) or 'client'."
            );
        }
    }

    Ok(())
}
