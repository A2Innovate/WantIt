export async function getLocation(): Promise<{ lat: number; lng: number }> {
  if (!navigator.geolocation) {
    return {
      lat: 37.78,
      lng: -122.419
    };
  }

  return new Promise((resolve, reject) => {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          lat: position.coords.latitude,
          lng: position.coords.longitude
        });
      },
      (error) => {
        reject(error);
      }
    );
  });
}
