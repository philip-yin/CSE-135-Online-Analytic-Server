<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Sales Analytics</title>
</head>
<body>
	<table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%	
				String rows = request.getParameter("rows");
				String order = request.getParameter("order");
				String changeable = request.getParameter("hide");
				String row_offset = request.getParameter("row_offset");
				String col_offset = request.getParameter("col_offset");
				String cat = request.getParameter("filter");
				
				int ro, co, filter;
				int cat_id = 0;
				
				if(row_offset == null){
					ro = 0;
				}
				else{
					ro = Integer.parseInt(row_offset);
				}
				if(col_offset == null){
					co = 0;
				}
				else{
					co = Integer.parseInt(col_offset);
				}
				if(cat == null || cat.equals("all")){
					filter = 0;
				}
				else{
					filter = 1;
				}
				
				String next_msg = "";
			
				Connection conn;
				Statement stmt, stmt2, stmt3, stmt4;
				ResultSet rs, rs2, rs3, rs4;
				try {
					// Registering Postgresql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/CSE135", "postgres", "cse135");
					
					stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
					stmt2 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
					stmt3 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
					stmt4 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
					
					rs4 = stmt4.executeQuery("select category_name, id from category");
					if(filter == 1){
						while(rs4.next()){
							if(rs4.getString("category_name").equals(cat)){
								cat_id = rs4.getInt("id");
								break;
							}
						}
						rs4.beforeFirst();
					}
					// Create the statement
					%>
					
					<table>
						<tr><th></th>
						<%
						//for columns
						//default/order is alphabetical
						if(order == null || order.equals("alphabetical")){
							if(filter == 0){
								rs3 = stmt3.executeQuery("select product_name, id, sum(total) as total from "+
										"(select pr.product_name, pr.id, 0 as total from product pr union "+
												"select pr.product_name, pr.id, sum(pc.quantity * pc.price) as total from "+
												"product pr, products_in_cart pc, shopping_cart sc "+
												"where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id "+
												"group by pr.product_name, pr.id) as temp "+
												"group by product_name, id "+
												"order by product_name limit 10 offset " + co);
							}
							else{
								rs3 = stmt3.executeQuery("select product_name, id, sum(total) as total from "+
										"(select pr.product_name, pr.id, pr.category_id, 0 as total from product pr union "+
												"select pr.product_name, pr.id, pr.category_id, sum(pc.quantity * pc.price) as total from "+
												"product pr, products_in_cart pc, shopping_cart sc "+
												"where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id "+
												"group by pr.product_name, pr.id) as temp "+
												"where category_id = " + cat_id + " " +
												"group by product_name, id "+
												"order by product_name limit 10 offset " + co);
							}
							while(rs3.next()){
								String str = rs3.getString("product_name");
								if(str.length() > 10)
									str = str.substring(0, 10);
								%><th><b><%=str%><br>(<%=rs3.getInt("total")%>)</b></th><%
							}
						}
						//order is Top-k
						else if(order.equals("top-k")){
							if(filter == 0){
								rs3 = stmt3.executeQuery("select product_name, id, sum(total) as total from "+
										"(select pr.product_name, pr.id, 0 as total from product pr union "+
										"select pr.product_name, pr.id, sum(pc.quantity * pc.price) as total from "+
										"product pr, products_in_cart pc, shopping_cart sc "+
										"where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id "+
										"group by pr.product_name, pr.id) as temp "+
										"group by product_name, id "+
										"order by total desc limit 10 offset " + co);
							}
							else{
								rs3 = stmt3.executeQuery("select product_name, id, sum(total) as total from "+
										"(select pr.product_name, pr.id, pr.category_id, 0 as total from product pr union "+
										"select pr.product_name, pr.id, pr.category_id, sum(pc.quantity * pc.price) as total from "+
										"product pr, products_in_cart pc, shopping_cart sc "+
										"where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id "+
										"group by pr.product_name, pr.id) as temp "+
										"where category_id = " + cat_id + " " +
										"group by product_name, id "+
										"order by total desc limit 10 offset " + co);
							}
							while(rs3.next()){
								String str = rs3.getString("product_name");
								if(str.length() > 10)
									str = str.substring(0, 10);
								%><th><b><%=str%><br>(<%=rs3.getInt("total")%>)</b></th><%
							}
						}
						//order is other value
						else{
							rs3 = stmt3.executeQuery("select * from product where product_name <> product_name");
							%><b>Error! Invalid Order input.</b><%
						}
						%>
						</tr>
						<% 
						//for rows
						//default/rows are customers
						if(rows == null || rows.equals("customers")){
							next_msg = "Next 20 customers";
							//default/order is Alphabetical in rows
							if(order == null || order.equals("alphabetical")){
								if(filter == 0){
									rs = stmt.executeQuery("select person_name, id, sum(total) as total from "+
											"(select p.person_name, p.id, sum(pc.quantity * pc.price) As total from "+
													"person p, shopping_cart s, products_in_cart pc "+
													"where s.person_id = p.id and pc.cart_id = s.id and s.is_purchased = true "+
													"group by p.person_name, p.id union "+
													"select p2.person_name, p2.id, 0 As total from person p2) As temp "+
													"group by person_name, id "+
													"order by person_name limit 20 offset " + ro);
								}
								else{
									rs = stmt.executeQuery("select person_name, id, sum(total) as total from "+
											"(select person_name, id, sum(total) as total from "+
													"(select p.person_name, p.id, pr.category_id, sum(pc.quantity * pc.price) As total from "+
													"person p, shopping_cart s, products_in_cart pc, product pr "+
													"where s.person_id = p.id and pc.cart_id = s.id and s.is_purchased = true and pc.product_id = pr.id "+
													"group by p.person_name, p.id, pr.category_id union "+
													"select p2.person_name, p2.id, 0 as category_id, 0 As total from person p2) As temp "+
													"where category_id = " + cat_id + " "+
													"group by person_name, id "+
													"union select person_name, id, 0 as total from person) as temp2 "+
													"group by person_name, id "+
													"order by person_name limit 20 offset " + ro);
								}
							}
							//order is Top-K
							else if(order.equals("top-k")){
								if(filter == 0){
									rs = stmt.executeQuery("select person_name, id, sum(total) as total from "+
											"(select p.person_name, p.id, sum(pc.quantity * pc.price) As total from "+
													"person p, shopping_cart s, products_in_cart pc "+
													"where s.person_id = p.id and pc.cart_id = s.id and s.is_purchased = true "+
													"group by p.person_name, p.id union "+
													"select p2.person_name, p2.id, 0 As total from person p2) As temp "+
													"group by person_name, id "+
													"order by total desc limit 20 offset " + ro);
								}
								else{
									rs = stmt.executeQuery("select person_name, id, sum(total) as total from "+
											"(select person_name, id, sum(total) as total from "+
													"(select p.person_name, p.id, pr.category_id, sum(pc.quantity * pc.price) As total from "+
													"person p, shopping_cart s, products_in_cart pc, product pr "+
													"where s.person_id = p.id and pc.cart_id = s.id and s.is_purchased = true and pc.product_id = pr.id "+
													"group by p.person_name, p.id, pr.category_id union "+
													"select p2.person_name, p2.id, 0 as category_id, 0 As total from person p2) As temp "+
													"where category_id = " + cat_id + " "+
													"group by person_name, id "+
													"union select person_name, id, 0 as total from person) as temp2 "+
													"group by person_name, id "+
													"order by total desc limit 20 offset " + ro);
								}
							}
							//order is other value
							else{
								//select nothing
								rs =stmt.executeQuery("select * from person where person_name <> person_name");
								%><b>Error! Invalid Order input.</b><%
							}
							while (rs.next() ) {
								%><tr><td><b><%=rs.getString("person_name")%>(<%=rs.getInt("total") %>)</b></td><%
								
								rs2 = stmt2.executeQuery("select p.person_name, pc.product_id, pr.product_name, sum(pc.quantity * pc.price) As total from " +
										"person p, shopping_cart s, products_in_cart pc, product pr " +
										"where s.person_id = p.id and pc.cart_id = s.id and s.is_purchased = true and p.id = " +
                                        + rs.getInt("id") + " and pr.id = pc.product_id group by p.person_name, pc.product_id, pr.product_name");
								rs3.beforeFirst();
								//if person has purchase
								if(rs2.next()){
									while(rs3.next()){
										rs2.beforeFirst();
										
										int cell_id = rs3.getInt("id");
										int flag = 0;
										//search rs2 for this id
										while(rs2.next()){
											if(rs2.getInt("product_id") == cell_id){
												%><td><%=rs2.getInt("total")%></td><%
												flag = 1;
												break;
											}
										}
										if(flag == 0){
											%><td>0</td><%
										}
									}
								}
								//person does not have purchase
								else{
									while(rs3.next()){
										%><td>0</td><%
									}
								}
								%></tr><%
							} 
						}
						//rows are states
						else if(rows.equals("states")){
							next_msg = "Next 20 states";
							
							if(order == null || order.equals("alphabetical")){
								if(filter == 0){
									rs = stmt.executeQuery("select state_name, id, sum(total) As total from " +
											"(select s.state_name, s.id, sum(pc.quantity * pc.price) As total from "+
													"state s, person p, shopping_cart sc, products_in_cart pc "+
													"where s.id = p.state_id and sc.person_id = p.id and pc.cart_id = sc.id and sc.is_purchased = true "+
													"group by s.state_name, s.id union "+
													"select s2.state_name, s2.id, 0 As total from state s2) As temp "+
													"group by state_name, id "+
													"order by state_name limit 20 offset " + ro);
								}
								else{
									rs = stmt.executeQuery("select state_name, id, sum(total) as total from "+
											"(select state_name, id, sum(total) As total from "+
													"(select s.state_name, s.id, pr.category_id, sum(pc.quantity * pc.price) As total from "+
													"state s, person p, shopping_cart sc, products_in_cart pc, product pr "+
													"where s.id = p.state_id and sc.person_id = p.id and pc.cart_id = sc.id and sc.is_purchased = true and pc.product_id = pr.id "+
													"group by s.state_name, s.id, pr.category_id union "+
													"select s2.state_name, s2.id, 0 as category_id, 0 As total from state s2) As temp "+
													"where category_id = " + cat_id + " " +
													"group by state_name, id "+
													"union select state_name, id, 0 as total from state) as temp2 "+
													"group by state_name, id "+
													"order by state_name limit 20 offset " + ro);
								}
							}
							//order is Top-K
							else if(order.equals("top-k")){
								if(filter == 0){
									rs = stmt.executeQuery("select state_name, id, sum(total) As total from "+
											"(select s.state_name, s.id, sum(pc.quantity * pc.price) As total from "+
													"state s, person p, shopping_cart sc, products_in_cart pc "+
													"where s.id = p.state_id and sc.person_id = p.id and pc.cart_id = sc.id and sc.is_purchased = true "+
													"group by s.state_name, s.id union "+
													"select s2.state_name, s2.id, 0 As total from state s2) As temp "+
													"group by state_name, id "+
													"order by total desc limit 20 offset " + ro);
								}
								else{
									rs = stmt.executeQuery("select state_name, id, sum(total) as total from "+
											"(select state_name, id, sum(total) As total from "+
													"(select s.state_name, s.id, pr.category_id, sum(pc.quantity * pc.price) As total from "+
													"state s, person p, shopping_cart sc, products_in_cart pc, product pr "+
													"where s.id = p.state_id and sc.person_id = p.id and pc.cart_id = sc.id and sc.is_purchased = true and pc.product_id = pr.id "+
													"group by s.state_name, s.id, pr.category_id union "+
													"select s2.state_name, s2.id, 0 as category_id, 0 As total from state s2) As temp "+
													"where category_id = " + cat_id + " " +
													"group by state_name, id "+
													"union select state_name, id, 0 as total from state) as temp2 "+
													"group by state_name, id "+
													"order by total desc limit 20 offset " + ro);
								}
							}
							
							//order is other value
							else{
								rs =stmt.executeQuery("select * from state where state_name <> state_name");
								%><b>Error! Invalid Order input.</b><%
							}
							while (rs.next()) {
								%><tr><td><b><%=rs.getString("state_name")%>(<%=rs.getInt("total") %>)</b></td><%
								
								rs2 = stmt2.executeQuery("select s.state_name, pc.product_id, pr.product_name, sum(pc.quantity * pc.price) As total from " +
										"state s, person p, shopping_cart sc, products_in_cart pc, product pr " +
										"where s.id = p.state_id and sc.person_id = p.id and pc.cart_id = sc.id and sc.is_purchased = true " + 
										"and s.id = " + rs.getInt("id") + " and pr.id = pc.product_id group by s.state_name, pc.product_id, pr.product_name");
								
								rs3.beforeFirst();
								//the state has purchase
								if(rs2.next()){
									while(rs3.next()){
										rs2.beforeFirst();
										
										int cell_id = rs3.getInt("id");
										int flag = 0;
										//search rs2 for this id
										while(rs2.next()){
											if(rs2.getInt("product_id") == cell_id){
												%><td><%=rs2.getInt("total")%></td><%
												flag = 1;
												break;
											}
										}
										if(flag == 0){
											%><td>0</td><%
										}
									}
								}
								//state does not have purchase
								else{
									while(rs3.next()){
										%><td>0</td><%
									}
								}
								%></tr><%
							} 
						}
						//rows have other value
						else{
							rs =stmt.executeQuery("select * from state where state_name <> state_name");
							%><b>Error! Invalid Order input.</b><%
							%><b>Error! Invalid Rows input.</b><%
						}
						
					%>
					</table>
					<br>
					<br>
					
					<% if(changeable == null){ 
						%>
						<form action="analytics.jsp" method="GET">
							<%if(rows == null || rows.equals("customers")){
								%>
								<select name="rows">
									<option value="customers" selected>Customers</option>
									<option value="states">States</option>	
								</select>
								<%
							}
							else{
								%>
								<select name="rows">
									<option value="customers">Customers</option>
									<option value="states" selected>States</option>	
								</select>
								<%
							}%>
							
							<%if(order == null || order.equals("alphabetical")){
								%>
								<select name="order">
									<option value="alphabetical" selected>Alphabetical</option>
									<option value="top-k">Top-K</option>	
								</select>
								<%
							}
							else{
								%>
								<select name="order">
									<option value="alphabetical">Alphabetical</option>
									<option value="top-k" selected>Top-K</option>	
								</select>
								<%
							}%>
							
							<select name ="filter">
								<%
								if(cat == null || cat.equals("all")){
									%>
									<option value="all" selected>All</option>
									<%
								}
								else{
									%>
									<option value="all">All</option>
									<%
								}
								while(rs4.next()){
									if(rs4.getString("category_name").equals(cat)){
										%>
										<option value=<%=rs4.getString("category_name")%> selected><%=rs4.getString("category_name") %></option>
										<%
									}
									else{
										%>
										<option value=<%=rs4.getString("category_name")%>><%=rs4.getString("category_name") %></option>
										<%
									}
								}
								%>
							</select>
							
							<input type="submit" value="Run Query"/>
						</form>
						<%
					}%>
					<br>
					<br>
					<%
						rs.last();
						rs3.last();
						int lastrow = rs.getRow();
						int lastcol = rs3.getRow();
					%>
					
					<%
					if(lastrow == 20){
						%>
						
						<form action="analytics.jsp" method="GET">
							<%if(rows == null){
								%>
								<input type="hidden" name="rows" value="customers">
								<%
							}
							else{
								%>
								<input type="hidden" name="rows" value=<%=rows %>>
								<%
							}%>
							<%if(order == null){
								%>
								<input type="hidden" name="order" value="alphabetical">
								<%
							}
							else{
								%>
								<input type="hidden" name="order" value=<%=order %>>
								<%
							}%>
							<%
							if(filter == 0) {
								%>
									<input type="hidden" name="filter" value="all">
								<%
							}
							else{
								%>
									<input type="hidden" name="filter" value=<%=cat%>>
								<%
							}
							%>
							<input type="hidden" name="row_offset" value="<%=ro+20%>">
							<input type="hidden" name="col_offset" value="<%=co%>">
							<input type="hidden" name="hide" value="true">
							<input type="submit" value="<%=next_msg%>" >
						</form>
						<%	
					}
					%>
					<br>
					<%
					if(lastcol == 10){
						%>
						<form action="analytics.jsp" method="GET">
							<%if(rows == null){
								%>
								<input type="hidden" name="rows" value="customers">
								<%
							}
							else{
								%>
								<input type="hidden" name="rows" value=<%=rows %>>
								<%
							}%>
							<%if(order == null){
								%>
								<input type="hidden" name="order" value="alphabetical">
								<%
							}
							else{
								%>
								<input type="hidden" name="order" value=<%=order %>>
								<%
							}%>
							<%
							if(filter == 0) {
								%>
									<input type="hidden" name="filter" value="all">
								<%
							}
							else{
								%>
									<input type="hidden" name="filter" value=<%=cat%>>
								<%
							}
							%>
							<input type="hidden" name="row_offset" value="<%=ro%>">
							<input type="hidden" name="col_offset" value="<%=co+10%>">
							<input type="hidden" name="hide" value="true">
							<input type="submit" value="Next 10 products" >
						</form>
						<%
					}
					// Close the ResultSet
					//rs.close();
					// Close the Statement
					//stmt.close();
					// Close the Connection
					//conn.close();
				} catch (SQLException e) {
					%><%= e %><%
				}
			%>
		</td>
	</tr></table>
</body>
</html>