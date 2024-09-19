use std::ffi::CStr;
use std::os::raw::c_char;
use std::fs::OpenOptions;
use std::io::Write;
use screenshots::Screen;

#[no_mangle]
pub extern "C" fn take_s(path: *const libc::c_char) {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap() };
    println!("Message: {}", path);
    // format!("path, {path}!");

    let screens = Screen::all().unwrap();

    let scr = screens.first().unwrap();
    let image = scr.capture().unwrap();
    image.save(path).unwrap();
    println!("Screenshot saved to {path}");
    // "done".to_string()
}

fn collect_windows_logs() -> String {
    let logs = "Sample Log Data: Application Error, Source: ExampleApp, Event ID: 1000";
    logs.to_string()
}

fn save_log_to_file(log_data: &str, log_path: &str) {
    let mut file = OpenOptions::new()
        .write(true)
        .append(true)
        .create(true)
        .open(log_path)
        .unwrap();
    
    if let Err(e) = writeln!(file, "{}", log_data) {
        eprintln!("Couldn't write to file: {}", e);
    }
}
