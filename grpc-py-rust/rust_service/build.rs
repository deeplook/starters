fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = std::env::var("OUT_DIR")?;

    tonic_build::configure()
        .file_descriptor_set_path(format!("{out_dir}/bridge_descriptor.bin"))
        .build_client(true)
        .build_server(true)
        .compile(&["../proto/bridge.proto"], &["../proto"])?;
    println!("cargo:rerun-if-changed=../proto/bridge.proto");
    Ok(())
}
