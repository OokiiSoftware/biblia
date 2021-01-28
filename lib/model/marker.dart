
enum Marker {
  none, green, cyan, pink, orange, purple
}

Marker markerFromString(String value) {
  if (value == null)
    value = '';
  switch(value) {
    case 'Marker.none':
      return Marker.none;
    case 'Marker.green':
      return Marker.green;
    case 'Marker.cyan':
      return Marker.cyan;
    case 'Marker.pink':
      return Marker.pink;
    case 'Marker.orange':
      return Marker.orange;
    case 'Marker.purple':
      return Marker.purple;
    default:
      return Marker.none;
  }
}
