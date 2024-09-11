use std::ffi::CStr;

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
