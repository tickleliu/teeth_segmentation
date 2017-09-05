import java.util.LinkedList;
import java.util.List;

public class Face {

	float normalX;
	float normalY;
	float normalZ;

	List<Integer> vertexs;

	int attribute;

	public Face() {
		vertexs = new LinkedList<Integer>();
	}

	@Override
	public boolean equals(Object obj) {
		// TODO Auto-generated method stub
		return super.equals(obj);
	}

	@Override
	public int hashCode() {
		// TODO Auto-generated method stub
		return super.hashCode();
	}
}
