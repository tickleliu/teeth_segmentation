/**
 * 节点的坐标
 * */
public class Vertex {
	final public Float x;
	final public Float y;
	final public Float z;

	public Vertex(float x, float y, float z) {
		// TODO Auto-generated constructor stub
		this.x = x;
		this.y = y;
		this.z = z;
	}

	@Override
	public boolean equals(Object obj) {
		// TODO Auto-generated method stub
		if (obj instanceof Vertex && obj != null) {
		} else {
			return false;
		}
		Vertex double1 = (Vertex) obj;
		double eps = Math.abs(double1.x - this.x)
				+ Math.abs(double1.y - this.y) + Math.abs(double1.z - this.z);
		if (eps < 0.001) {
			return true;
		} else {
			return false;
		}
	}

	@Override
	public int hashCode() {
		// TODO Auto-generated method stub
		StringBuilder hashString = new StringBuilder();
		hashString.append(this.x.intValue());
		hashString.append(this.y.intValue());
		hashString.append(this.z.intValue());
		return hashString.toString().hashCode();
	}
}
