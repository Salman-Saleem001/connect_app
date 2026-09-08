/**
 * Local file → Blob for Firebase Storage.
 * XMLHttpRequest is the reliable React Native pattern for file:// / content:// URIs
 * (fetch often returns empty blobs for DocumentPicker files).
 */
export function readUriAsBlob(uri: string): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.onload = () => {
      const response = xhr.response;
      if (response instanceof Blob && response.size > 0) {
        resolve(response);
        return;
      }
      reject(new Error('Could not read the selected file.'));
    };
    xhr.onerror = () => reject(new Error('Could not read the selected file.'));
    xhr.responseType = 'blob';
    xhr.open('GET', uri, true);
    xhr.send(null);
  });
}
