<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<title>Log table</title>
	</head>
	<body>
	  <%response.setContentType("text/xml");%>
	  <%
	  try{
		int cat_id = Integer.parseInt(request.getParameter("cat"));
		Connection conn;
		Statement stmt;
		PreparedStatement stmt2, stmt3, stmt4;
		ResultSet rs, rs3, rs4;
		// Registering Postgresql JDBC driver
		Class.forName("org.postgresql.Driver");
		// Open a connection to the database
		conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/CSE135", "postgres", "cse135");
		stmt = conn.createStatement();
		stmt2 = conn.prepareStatement("select state_id from person where id = ?");
		//top 50 products with no filter at real time and precomputed
		if(cat_id == 0){
			stmt3 = conn.prepareStatement("select product_name, id, sum(total) as total from "+
					"(select product_name, id, category_id, sum(total) as total from "+
					"(select pr.product_name, pr.id, pr.category_id, 0 as total from product pr union "+
					"select pr.product_name, pr.id, pr.category_id, sum(pc.quantity * pc.price) as total from "+
					"product pr, products_in_cart pc, shopping_cart sc "+
					"where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id "+
					"group by pr.product_name, pr.id) as temp "+
					"group by product_name, id, category_id) as tempt "+
					"group by product_name, id order by total desc limit 50",
					ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
			stmt4 = conn.prepareStatement("select product_name, id, sum(total) as total from temp3 group by product_name, id order by total desc limit 50",
					ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		}
		//get top 50 products of certain category at real time and precomputed
		else{
			stmt3 = conn.prepareStatement("select product_name, id, sum(total) as total from "+
					"(select product_name, id, category_id, sum(total) as total from "+
					"(select pr.product_name, pr.id, pr.category_id, 0 as total from product pr union "+
					"select pr.product_name, pr.id, pr.category_id, sum(pc.quantity * pc.price) as total from "+
					"product pr, products_in_cart pc, shopping_cart sc "+
					"where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id "+
					"group by pr.product_name, pr.id) as temp "+
					"group by product_name, id, category_id) as tempt "+
					"where category_id = ? "+
					"group by product_name, id order by total desc limit 50",
					ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
			stmt4 = conn.prepareStatement("select product_name, id, sum(total) as total from temp3 where category_id = ? group by product_name, id order by total desc limit 50",
					ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		}
		//rs has the log table
		rs = stmt.executeQuery("select * from log");
		//rs3 has top 50 products in real time
		//rs4 has top 50 products precomputed
		if(cat_id == 0){
			rs3 = stmt3.executeQuery();
			rs4 = stmt4.executeQuery();
		}
		else{
			stmt3.setInt(1, cat_id);
			rs3 = stmt3.executeQuery();
			stmt4.setInt(1, cat_id);
			rs4 = stmt4.executeQuery();
		}
		int i = 0;
		%><table><%
		
		while(rs.next()){
			i++;
			//rs2 has the person id
			stmt2.setInt(1, rs.getInt("person_id"));
			ResultSet rs2 = stmt2.executeQuery();
			rs2.next();
			
			%>
			<tr id ="<%=i%>">
			<td><%=rs2.getInt("state_id")%></td>
			<td><%=rs.getInt("product_id")%></td>
			<td><%=rs.getInt("total")%></td>
			</tr>
			<%
		}
		
		%>
		</table>
		<%
		//products now in top 50 but not before will be reported(re)
		i = 0;
		rs3.beforeFirst();
		rs4.beforeFirst();
		while(rs3.next()){
			rs4.beforeFirst();
			int re_id = rs3.getInt("id");
			//set flag to 1 if products now in top 50 also was in top 50 before
			int flag = 0;
			while(rs4.next()){
				int temp_id = rs4.getInt("id");
				if(re_id == temp_id){
					flag = 1;
					break;
				}
			}
			//report if flag is 0(now in top 50 but not in before)
			if(flag == 0){
				i++;
				%><p id="re_<%=i%>"><%=rs3.getString("product_name")%></p><%
			}
		}
		//products now not in top 50 but in before will be marked purple(pr)
		i = 0;
		rs3.beforeFirst();
		rs4.beforeFirst();
		while(rs4.next()){
			rs3.beforeFirst();
			int pr_id = rs4.getInt("id");
			//set flag to 1 if products was in top 50 still in top 50 now
			int flag = 0;
			while(rs3.next()){
				int temp_id = rs3.getInt("id");
				if(pr_id == temp_id){
					flag = 1;
					break;
				}
			}
			//report if flag is 0(was in top 50 but not now)
			if(flag == 0){
				i++;
				%><p id="pr_<%=i%>"><%=pr_id%></p><%
			}
		}
		rs.close();
		rs3.close();
		rs4.close();
		stmt.close();
		stmt2.close();
		stmt3.close();
		stmt4.close();
		conn.close();
	  }
	  catch(SQLException e){
		  %><%= e %><%
	  }
	  %>
	</body>
</html>