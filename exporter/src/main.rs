use http_body_util::{BodyExt, Full};
use hyper::body::Bytes;
use hyper::{Method, Request};
use hyper_util::client::legacy::Client;
use hyperlocal::{UnixClientExt, UnixConnector, Uri};
use std::error::Error;
// use tokio::io::{self, AsyncWriteExt as _};
use std::process::Command;

const SNAPD_SOCKET: &str = "/run/snapd-snap.socket";

async fn snapdapi_req() -> Result<serde_json::Value, Box<dyn Error + Send + Sync>> {
    let url: hyperlocal::Uri = Uri::new(SNAPD_SOCKET, "/v2/snapctl").into();

    let client: Client<UnixConnector, Full<Bytes>> = Client::unix();

    let snap_context = std::env::var("SNAP_CONTEXT")?;

    let request_body = format!(
        r#"{{"context-id":"{}","args":["get","env", "envfile", "apps"]}}"#,
        snap_context
    );

    let req: Request<Full<Bytes>> = Request::builder()
        .method(Method::POST)
        .uri(url)
        .body(Full::from(request_body))?;

    let mut res = client.request(req).await?;

    let mut body: Vec<u8> = Vec::new();

    while let Some(frame_result) = res.frame().await {
        let frame = frame_result?;

        if let Some(segment) = frame.data_ref() {
            body.extend_from_slice(segment);
        }
    }

    Ok(serde_json::from_slice(&body)?)
}


#[tokio::main]
async fn main() -> Result<(), Box<dyn Error + Send + Sync>> {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: {} <app-path>", args[0]);
        std::process::exit(1);
    }

    let json = snapdapi_req().await?;

    let command = args[1].clone();

    println!("Response JSON: \n\n{}", json);

    Command::new(command).status()?;

    Ok(())
}
