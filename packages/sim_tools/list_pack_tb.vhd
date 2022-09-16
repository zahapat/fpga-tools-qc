    use std.textio.all;

    -- use lib_sim.list_string_pack_tb.all;

    -- Prototypes of the subprograms
    package list_pack_tb is

        generic(type data_type);

        -- List as protected type
        -- print("Inserting four strings at indexes 0,1,1,-1");
        -- l.insert(0, "string_at_index_0");
        -- l.insert(1, "string_at_index_1");
        -- l.insert(1, "string_at_index_2");
        -- l.insert(-1, "string_at_index_3");
        
        -- print("Delete elements at indexes: 1, -1");
        -- l.delete(1);
        -- l.delete(-1);
        -- l.append("string_at_index1");
        -- l.clear;
        type list is protected

            -- Add an item to the end of the list
            -- @param str: The data to append
            procedure append(data : data_type);


            -- Add an item to the list
            -- @param index The list slot to insert <data> at.
            --    A zero or positive index counts from the start of the list.
            --    A negative index counts from the end of the list.
            --    Example:
            --      Insert at the first element: insert(0, my_data)
            --      Insert at the second last element: insert(-1, my_data)
            -- @param data The item to insert at <index>.
            procedure insert(index : integer; data : data_type);


            -- Get an item from the list without deleting it
            -- @param index The list index of the item to get.
            --    Like for insert(), the list index can be negative.
            --    But unlike insert(), insert(-1) returns the last object.
            -- @return The dynamically allocate data_type object
            impure function get(index : integer) return data_type;


            -- Remove an item from the list and free the memory it used
            -- @param index The list index of the object to delete.
            --    The behavor is identical to the get() index parameter.
            procedure delete(index : integer);


            -- Delete all items from the list and free the memory
            procedure clear;


            -- Get the number of items in the list
            -- @return The list's length
            impure function length return integer;

        end protected;

    end package;

    
    -- Body of the subprograms
    package body list_pack_tb is

        type list is protected body

            type data_ptr is access data_type;
            type item;
            type item_ptr is access item;
            type item is record
                data : data_ptr;
                next_item : item_ptr;
            end record;

            variable root : item_ptr;
            variable length_i : integer := 0;


            -- Append an element of a certain data type to the list using insert procedure
            procedure append(data : data_type) is
            begin
                insert(length_i, data);
            end procedure;


            -- Insert an element of a certain data type to the specific position 'item_ptr'
            procedure insert(index : integer; data : data_type) is
                variable new_item : item_ptr;
                variable node : item_ptr;
                variable index_v : integer;
            begin
                -- Create the new object
                new_item := new item;
                new_item.data := new data_type'(data);

                -- Restrict to index to the list range
                if index >= length_i then
                    index_v := length_i;
                elsif index <= -length_i then
                    index_v := 0;
                else
                    index_v := index mod length_i;
                end if;

                if index_v = 0 then
                    -- The new object becomes root when inserting at position 0
                    new_item.next_item := root;
                    root := new_item;
                else
                    -- Find the node to insert after
                    node := root;
                    for i in 2 to index_v loop
                        node := node.next_item;
                    end loop;

                    -- Insert the new item
                    new_item.next_item := node.next_item;
                    node.next_item := new_item;
                end if;

                length_i := length_i + 1;
            end procedure;


            -- Translate a negative or positive get index to a positive index
            impure function get_index(index : integer) return integer is
            begin
                assert index >= -length_i and index < length_i
                report "get index out of list range"
                severity failure;

                return index mod length_i;
            end function;


            -- Get a node from the list without deleting it
            impure function get_node(index : integer) return item_ptr is
                variable node : item_ptr;
            begin
                node := root;
                for i in 1 to get_index(index) loop
                    node := node.next_item;
                end loop;

                return node;
            end function;


            -- Get element located at a certain index
            impure function get(index : integer) return data_type is
            begin
                return get_node(index).data.all;
            end function;


            -- Delete element located at a certain index
            procedure delete(index : integer) is
                constant index_c : integer := get_index(index);
                variable node : item_ptr;
                variable parent_node : item_ptr;
            begin
                if index_c = 0 then
                    node := root;
                    root := root.next_item;
                else
                    parent_node := get_node(index - 1);
                    node := parent_node.next_item;
                    parent_node.next_item := node.next_item;
                end if;

                deallocate(node.data);
                deallocate(node);

                length_i := length_i -1;
            end procedure;


            -- Clear content of the list
            procedure clear is
            begin
                while length_i > 0 loop
                    delete(0);
                end loop;
            end procedure;


            -- Get total number of elements in the list
            impure function length return integer is
            begin
                return length_i;
            end function;

        end protected body;

    end package body;